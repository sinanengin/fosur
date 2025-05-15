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
            return mockNewsData.filter { $0.type == .campaign }
        case .announcements:
            return mockNewsData.filter { $0.type == .announcement }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Duyurular")
                    .font(CustomFont.bold(size: 28))
                    .padding(.top, 24)
                    .padding(.horizontal)

                // Kategori Butonları
                HStack(spacing: 8) {
                    CategoryButton(title: "Tümü", isSelected: selectedCategory == .all) {
                        withAnimation { selectedCategory = .all }
                    }
                    CategoryButton(title: "Kampanyalar", isSelected: selectedCategory == .campaigns) {
                        withAnimation { selectedCategory = .campaigns }
                    }
                    CategoryButton(title: "Duyurular", isSelected: selectedCategory == .announcements) {
                        withAnimation { selectedCategory = .announcements }
                    }
                }
                .padding(.horizontal)

                // Scrollable News Cards
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredNews) { news in
                                NewsCardView(news: news)
                                    .onTapGesture {
                                        selectedNews = news
                                        showDetail = true
                                    }
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
            .sheet(item: $selectedNews) { news in
                NewsDetailView(news: news)
            }
            .background(Color.white)
        }
    }
}
