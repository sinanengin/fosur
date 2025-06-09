import SwiftUI

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetDestination?
    @Published var presentedFullScreenCover: FullScreenDestination?
    @Published var selectedCityCode: String = ""
    @Published var selectedBrand: VehicleBrand? = nil
    @Published var selectedVehicle: Vehicle? = nil
    @Published var currentOrder: Order? = nil
    
    enum SheetDestination: Identifiable {
        case auth
        case terms
        case privacy
        case cityCodePicker(String)
        
        var id: String {
            switch self {
            case .auth: return "auth"
            case .terms: return "terms"
            case .privacy: return "privacy"
            case .cityCodePicker: return "cityCodePicker"
            }
        }
    }
    
    enum FullScreenDestination: Identifiable {
        case brandSelection
        case modelSelection
        case addVehicle
        case editVehicle
        case phoneLogin
        
        var id: String {
            switch self {
            case .brandSelection: return "brandSelection"
            case .modelSelection: return "modelSelection"
            case .addVehicle: return "addVehicle"
            case .editVehicle: return "editVehicle"
            case .phoneLogin: return "phoneLogin"
            }
        }
    }
    
    func navigateTo(_ destination: any Hashable) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        navigationPath.removeLast()
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func presentSheet(_ destination: SheetDestination) {
        presentedSheet = destination
    }
    
    func presentFullScreen(_ destination: FullScreenDestination) {
        print("🔧 NavigationManager: presentFullScreen(\(destination)) çağrıldı")
        presentedFullScreenCover = destination
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        print("🔧 NavigationManager: dismissFullScreen() çağrıldı")
        presentedFullScreenCover = nil
    }
    
    func startOrderFlow(vehicle: Vehicle, address: Address, services: [Service], appState: AppState) {
        let totalAmount = services.reduce(0) { $0 + $1.price }
        currentOrder = Order(
            vehicleId: vehicle.id,
            vehicle: vehicle,
            address: address,
            selectedServices: services,
            serviceDate: Date(),
            serviceTime: "",
            totalAmount: totalAmount
        )
        
        // Güvenli şekilde fullscreen açmak için DispatchQueue kullan
        DispatchQueue.main.async {
            appState.showDateTimeSelection = true
        }
    }
    
    func showOrderSummaryScreen(appState: AppState) {
        DispatchQueue.main.async {
            appState.showDateTimeSelection = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            appState.showOrderSummary = true
        }
    }
    
    func showPaymentScreen(appState: AppState) {
        DispatchQueue.main.async {
            appState.showOrderSummary = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            appState.showPayment = true
        }
    }
    
    func hideAllOrderScreens(appState: AppState) {
        DispatchQueue.main.async {
            appState.showDateTimeSelection = false
            appState.showOrderSummary = false
            appState.showPayment = false
        }
    }
    
    func updateOrderDateTime(date: Date, time: String) {
        guard var order = currentOrder else { return }
        currentOrder = Order(
            id: order.id,
            vehicleId: order.vehicleId,
            vehicle: order.vehicle,
            address: order.address,
            selectedServices: order.selectedServices,
            serviceDate: date,
            serviceTime: time,
            totalAmount: order.totalAmount,
            travelFee: order.travelFee,
            status: order.status,
            createdAt: order.createdAt
        )
    }
    
    func clearOrderFlow() {
        currentOrder = nil
    }
} 