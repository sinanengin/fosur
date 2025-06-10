import Foundation
import SwiftUI

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var selectedBrand: MockVehicleBrand? = nil
    @Published var selectedVehicle: Vehicle? = nil
    @Published var selectedCityCode: String = ""
    @Published var presentedSheet: SheetDestination? = nil
    @Published var presentedFullScreenCover: FullScreenCoverDestination? = nil
    @Published var currentOrder: Order? = nil
    
    func navigateTo<T: Hashable>(_ destination: T) {
        navigationPath.append(destination)
    }
    
    func goBack() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func presentFullScreen(_ destination: FullScreenCoverDestination) {
        presentedFullScreenCover = destination
    }
    
    func dismissFullScreen() {
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

enum SheetDestination: Identifiable {
    case auth
    case terms
    case privacy
    case cityCodePicker
    
    var id: String {
        switch self {
        case .auth: return "auth"
        case .terms: return "terms"
        case .privacy: return "privacy"
        case .cityCodePicker: return "cityCodePicker"
        }
    }
}

enum FullScreenCoverDestination: Identifiable {
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