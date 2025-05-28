import Foundation

let mockNewsData: [NewsItem] = [
    NewsItem(
        title: "Büyük İndirim!",
        description: "İlk alışverişinizde %50 indirim. Bu fırsatı kaçırmayın!",
        image: "newsCover",
        type: .campaign,
        date: "20 Mart 2024",
        additionalInfo: [
            "İlk alışverişe özel %50 indirim",
            "Tüm hizmetlerde geçerli",
            "31 Mart'a kadar süre",
            "Online randevu ile anında faydalanın"
        ],
        category: .campaigns,
        isPinned: true
    ),
    NewsItem(
        title: "Ücretsiz Teslimat",
        description: "Bugüne özel ücretsiz teslimat fırsatı! Araçlarınızı biz alıp getirelim.",
        image: "newsCover",
        type: .campaign,
        date: "18 Mart 2024",
        additionalInfo: [
            "Ücretsiz teslimat hizmeti",
            "20 km yarıçap içinde geçerli",
            "Sadece bugün",
            "Online randevu şart"
        ],
        category: .campaigns
    ),
    NewsItem(
        title: "Yeni Üyelik Kampanyası",
        description: "Üye olanlara özel avantajlar ve indirimler sizleri bekliyor.",
        image: "newsCover",
        type: .campaign,
        date: "15 Mart 2024",
        additionalInfo: [
            "Hoş geldin indirimi",
            "Özel üye fırsatları",
            "Puan kazanma sistemi",
            "Doğum günü hediyesi"
        ],
        category: .campaigns
    ),
    NewsItem(
        title: "Şube Taşınıyor",
        description: "Yeni adresimizle çok yakında hizmetinizdeyiz. Daha geniş ve modern bir mekanda sizleri bekliyoruz.",
        image: "newsCover",
        type: .announcement,
        date: "12 Mart 2024",
        additionalInfo: [
            "Yeni lokasyon: Bağdat Caddesi No:123",
            "Daha geniş otopark",
            "Modern bekleme salonu",
            "7/24 hizmet"
        ],
        category: .announcements,
        isPinned: true
    ),
    NewsItem(
        title: "Çalışma Saatleri Güncellendi",
        description: "Artık daha uzun saatlerde hizmetinizdeyiz. 7/24 hizmet veriyoruz.",
        image: "newsCover",
        type: .announcement,
        date: "10 Mart 2024",
        additionalInfo: [
            "7/24 hizmet",
            "Tüm şubelerde geçerli",
            "Online randevu sistemi",
            "Acil durum desteği"
        ],
        category: .announcements
    ),
    NewsItem(
        title: "Hizmet Kalitemizi Artırıyoruz",
        description: "Müşteri memnuniyeti için çalışıyoruz! Yeni ekipmanlar ve eğitimli personel ile hizmetinizdeyiz.",
        image: "newsCover",
        type: .announcement,
        date: "5 Mart 2024",
        additionalInfo: [
            "Yeni temizlik ekipmanları",
            "Eğitimli personel",
            "Kalite kontrol sistemi",
            "Müşteri geri bildirim sistemi"
        ],
        category: .announcements
    )
]
