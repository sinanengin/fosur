import SwiftUI

enum TabItem: String, CaseIterable {
    case campaigns = "Kampanyalar"
    case myVehicles = "Araçlarım"
    case callUs = "Bizi Çağır!"
    case messages = "Mesajlar"
    case profile = "Profil"

    var icon: String {
        switch self {
        case .campaigns: return "percent"
        case .myVehicles: return "car.fill"
        case .callUs: return "bell.fill"
        case .messages: return "bubble.left.fill"
        case .profile: return "person.fill"
        }
    }
}
