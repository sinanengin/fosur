import SwiftUI

struct NewsView: View {
    @StateObject private var newsService = NewsService.shared
    @State private var selectedCategory: NewsCategory = .all
    @State private var showDetail = false
    @State private var selectedNews: AnnouncementData?
    @State private var errorMessage = ""
    @State private var showError = false

    var filteredNews: [AnnouncementData] {
        let allNews = newsService.announcements
        
        if let backendType = selectedCategory.backendType {
            return allNews.filter { $0.type.lowercased() == backendType }
        } else {
            return allNews // "Tümü" seçili ise hepsini göster
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Haberler")
                .font(CustomFont.bold(size: 28))
                .padding(.horizontal)
                .padding(.top, 16)

            // Kategori Butonları
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(NewsCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation { selectedCategory = category }
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Scrollable News Cards
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if newsService.isLoading {
                            // Loading state - hem ilk yükleme hem refresh için
                            ForEach(0..<3, id: \.self) { _ in
                                NewsCardLoadingView()
                            }
                        } else if filteredNews.isEmpty && !newsService.isLoading {
                            // Empty state - sadece loading değilken göster
                            VStack(spacing: 16) {
                                Image(systemName: "newspaper")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray)
                                
                                Text("Henüz haber bulunmuyor")
                                    .font(CustomFont.medium(size: 18))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(filteredNews) { news in
                                NewsCardView(news: news)
                                    .onTapGesture {
                                        selectedNews = news
                                        showDetail = true
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .id("TOP")
                }
                .refreshable {
                    await loadNews()
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
        .background(Color("BackgroundColor"))
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
            Button("Tekrar Dene") {
                Task { await loadNews() }
            }
        } message: {
            Text(errorMessage)
        }
        .task {
            if newsService.announcements.isEmpty {
                await loadNews()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadNews() async {
        do {
            try await newsService.fetchAnnouncements()
        } catch {
            print("❌ NewsView: Haber yükleme hatası: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}


// MARK: - Loading View
struct NewsCardLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 160)
                .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 14)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NewsView()
}
