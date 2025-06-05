import SwiftUI

class NavigationManager: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetDestination?
    @Published var presentedFullScreenCover: FullScreenDestination?
    @Published var selectedCityCode: String = ""
    @Published var selectedBrand: VehicleBrand? = nil
    @Published var selectedVehicle: Vehicle? = nil
    
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
} 