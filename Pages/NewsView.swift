import SwiftUI

struct NewsView: View {
    @State private var selectedCategory: NewsCategory = .all
    @State private var showDetail = false
    @State private var selectedNews: (title: String, description: String, image: String)?

    var filteredNews: [NewsItem] {
        switch selectedCategory {
        case .all:
            return newsData
        case .campaigns:
            return newsData.filter { $0.type == .campaign }
        case .announcements:
            return newsData.filter { $0.type == .announcement }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Duyurular")
                    .font(CustomFont.bold(size: 28))
                    .padding(.top, 24)
                    .padding(.horizontal)

                // Kategori Butonları
                HStack {
                    CategoryButton(title: "Tümü", isSelected: selectedCategory == .all) {
                        selectedCategory = .all
                    }
                    CategoryButton(title: "Kampanyalar", isSelected: selectedCategory == .campaigns) {
                        selectedCategory = .campaigns
                    }
                    CategoryButton(title: "Duyurular", isSelected: selectedCategory == .announcements) {
                        selectedCategory = .announcements
                    }
                }
                .padding(.horizontal)

                // Kartlar
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredNews, id: \.title) { news in
                            NewsCardView(imageName: news.image, title: news.title, description: news.description, type: news.type)
                                .onTapGesture {
                                    selectedNews = (news.title, news.description, news.image)
                                    showDetail = true
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showDetail) {
                if let news = selectedNews {
                    NewsDetailView(title: news.title, description: news.description, imageName: news.image)
                }
            }
        }
    }
}

enum NewsCategory {
    case all, campaigns, announcements
}

struct NewsItem {
    let title: String
    let description: String
    let image: String
    let type: NewsType
}

let newsData: [NewsItem] = [
    .init(title: "Büyük İndirim!", description: "İlk alışverişinizde %50 indirim.", image: "campaign1", type: .campaign),
    .init(title: "Kampanya 2", description: "Ücretsiz teslimat fırsatı!", image: "campaign2", type: .campaign),
    .init(title: "Kampanya 3", description: "Üyelikte özel avantajlar.", image: "campaign3", type: .campaign),
    .init(title: "Duyuru 1", description: "Çalışma saatlerimiz güncellendi.", image: "announcement1", type: .announcement),
    .init(title: "Duyuru 2", description: "Şubemiz taşınıyor.", image: "announcement2", type: .announcement),
    .init(title: "Duyuru 3", description: "Hizmet kalitemizi artırıyoruz!", image: "announcement3", type: .announcement),
]
