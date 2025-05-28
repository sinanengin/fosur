import Foundation

enum NewsCategory: String, CaseIterable {
    case all = "Tümü"
    case campaigns = "Kampanyalar"
    case announcements = "Duyurular"
}

enum NewsType: String {
    case campaign = "Kampanya"
    case announcement = "Duyuru"
}

struct NewsItem: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let image: String
    let type: NewsType
    let date: String
    let additionalInfo: [String]?
    let category: NewsCategory
    let isPinned: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        image: String,
        type: NewsType,
        date: String,
        additionalInfo: [String]? = nil,
        category: NewsCategory = .announcements,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.type = type
        self.date = date
        self.additionalInfo = additionalInfo
        self.category = category
        self.isPinned = isPinned
    }
}

// MARK: - Sample Data
extension NewsItem {
    static let sampleNews: [NewsItem] = [
        NewsItem(
            title: "Yeni Hizmetlerimiz",
            description: "Foşur olarak müşterilerimize daha iyi hizmet verebilmek için yeni hizmetlerimizi duyurmaktan mutluluk duyarız. Artık araçlarınızı daha uygun fiyatlarla ve daha kısa sürede temizleyebileceksiniz.",
            image: "news_placeholder",
            type: .announcement,
            date: "15 Mart 2024",
            additionalInfo: [
                "Yeni temizlik paketlerimiz ile tanışın",
                "Özel indirimler ve kampanyalar",
                "7/24 müşteri desteği",
                "Online randevu sistemi"
            ],
            category: .announcements,
            isPinned: true
        ),
        NewsItem(
            title: "Bahar Kampanyası",
            description: "Bahar aylarında araçlarınızı Foşur ile temizletin, %20 indirim kazanın! Kampanya 1 Nisan'a kadar geçerlidir.",
            image: "news_placeholder",
            type: .campaign,
            date: "1 Mart 2024",
            additionalInfo: [
                "%20 indirim fırsatı",
                "Tüm temizlik paketlerinde geçerli",
                "1 Nisan'a kadar süre",
                "Online randevu ile anında faydalanın"
            ],
            category: .campaigns
        ),
        NewsItem(
            title: "Yeni Şubemiz Açıldı",
            description: "Foşur'un yeni şubesi Kadıköy'de hizmetinize açıldı. Yeni şubemizde tüm hizmetlerimizden faydalanabilirsiniz.",
            image: "news_placeholder",
            type: .announcement,
            date: "28 Şubat 2024",
            additionalInfo: [
                "Kadıköy'de yeni lokasyon",
                "7/24 hizmet",
                "Ücretsiz otopark",
                "Online randevu imkanı"
            ],
            category: .announcements
        )
    ]
}
