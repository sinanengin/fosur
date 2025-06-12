import Foundation
import SwiftUI

// Local Order model - NavigationManager için
struct LocalOrder: Identifiable, Codable {
    let id: UUID
    let vehicleId: UUID
    let vehicle: Vehicle
    let address: Address
    let selectedServices: [Service]
    let serviceDate: Date
    let serviceTime: String
    let totalAmount: Double
    let travelFee: Double
    let status: String
    let createdAt: Date
    
    // Convenience initializer
    init(vehicleId: UUID, vehicle: Vehicle, address: Address, selectedServices: [Service], serviceDate: Date, serviceTime: String, totalAmount: Double, travelFee: Double = 0.0, status: String = "draft") {
        self.id = UUID()
        self.vehicleId = vehicleId
        self.vehicle = vehicle
        self.address = address
        self.selectedServices = selectedServices
        self.serviceDate = serviceDate
        self.serviceTime = serviceTime
        self.totalAmount = totalAmount
        self.travelFee = travelFee
        self.status = status
        self.createdAt = Date()
    }
    
    // Full initializer
    init(id: UUID, vehicleId: UUID, vehicle: Vehicle, address: Address, selectedServices: [Service], serviceDate: Date, serviceTime: String, totalAmount: Double, travelFee: Double, status: String, createdAt: Date) {
        self.id = id
        self.vehicleId = vehicleId
        self.vehicle = vehicle
        self.address = address
        self.selectedServices = selectedServices
        self.serviceDate = serviceDate
        self.serviceTime = serviceTime
        self.totalAmount = totalAmount
        self.travelFee = travelFee
        self.status = status
        self.createdAt = createdAt
    }
    
    var grandTotal: Double {
        return totalAmount + travelFee
    }
}

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var selectedBrand: MockVehicleBrand? = nil
    @Published var selectedVehicle: Vehicle? = nil
    @Published var selectedCityCode: String = ""
    @Published var presentedSheet: SheetDestination? = nil
    @Published var presentedFullScreenCover: FullScreenCoverDestination? = nil
    @Published var currentOrder: LocalOrder? = nil
    
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
        currentOrder = LocalOrder(
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
        guard let order = currentOrder else { return }
        currentOrder = LocalOrder(
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