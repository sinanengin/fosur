import SwiftUI

enum TabItem: String, CaseIterable {
    case news = "Haberler"
    case myVehicles = "Araçlarım"
    case callUs = "Bizi Çağır"
    case messages = "Mesajlar"
    case profile = "Profil"

    var iconName: String {
        switch self {
        case .news: return "newspaper"
        case .myVehicles: return "car"
        case .callUs: return "phone"
        case .messages: return "message"
        case .profile: return "person"
        }
    }
}
