enum TabItem: String, CaseIterable {
    case campaigns = "Duyurular"
    case myVehicles = "Araçlarım"
    case callUs = "Bizi Çağır!"
    case messages = "Mesajlar"
    case profile = "Profil"

    var iconName: String {
        switch self {
        case .campaigns: return "newsIcon"
        case .myVehicles: return "carIcon"
        case .callUs: return "glareIcon"
        case .messages: return "messagesIcon"
        case .profile: return "profileIcon"
        }
    }
}
