import Foundation

// MARK: - News Category for UI Filtering
enum NewsCategory: String, CaseIterable {
    case all = "Tümü"
    case campaign = "Kampanyalar"
    case serviceUpdate = "Hizmet Güncellemeleri"
    case systemAlert = "Sistem Uyarıları"
    case featureAnnouncement = "Özellik Duyuruları"
    
    // Backend type'ı ile eşleştirme
    var backendType: String? {
        switch self {
        case .all: return nil
        case .campaign: return "campaign"
        case .serviceUpdate: return "service_update"
        case .systemAlert: return "system_alert"
        case .featureAnnouncement: return "feature_announcement"
        }
    }
} 