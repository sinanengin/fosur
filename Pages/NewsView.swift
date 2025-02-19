import SwiftUI

struct NewsView: View {
    @State private var selectedCategory: NewsCategory = .all
    @State private var showDetail = false
    @State private var selectedNews: NewsItem?

    var filteredNews: [NewsItem] {
        switch selectedCategory {
        case .all:
            return mockNewsData
        case .campaigns:
            return mockNewsData.filter { $0.type == NewsType.campaign }
        case .announcements:
            return mockNewsData.filter { $0.type == NewsType.announcement }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                // Sayfa Başlığı
                Text("Duyurular")
                    .font(CustomFont.bold(size: 28))
                    .padding(.top, 24)
                    .padding(.horizontal)

                // Kategori Butonları
                HStack(spacing: 8) {
                    CategoryButton(title: "Tümü", isSelected: selectedCategory == .all) {
                        withAnimation {
                            selectedCategory = .all
                        }
                    }
                    CategoryButton(title: "Kampanyalar", isSelected: selectedCategory == .campaigns) {
                        withAnimation {
                            selectedCategory = .campaigns
                        }
                    }
                    CategoryButton(title: "Duyurular", isSelected: selectedCategory == .announcements) {
                        withAnimation {
                            selectedCategory = .announcements
                        }
                    }
                }
                .padding(.horizontal)

                // Kartlar + ScrollView + ScrollViewReader
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredNews, id: \.id) { news in
                                NewsCardView(news: news)
                                    .id(news.id)
                                    .onTapGesture {
                                        selectedNews = news
                                        showDetail = true
                                    }
                                    .transition(.opacity.combined(with: .scale)) // Animasyon
                            }
                        }
                        .padding(.horizontal)
                        .id("TOP")
                    }
                    .onChange(of: selectedCategory) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo("TOP", anchor: .top)
                        }
                    }
                }
            }
            .sheet(isPresented: $showDetail) {
                if let news = selectedNews {
                    NewsDetailView(news: news)
                }
            }
            .background(Color.white) // Arka plan temiz olsun
        }
    }
}
