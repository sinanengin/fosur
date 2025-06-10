import SwiftUI

struct NewsDetailView: View {
    var news: AnnouncementData
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var detailedNews: AnnouncementData?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack(spacing: 0) {
                // Aşağı çekme çizgisi
                Rectangle()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(width: 44, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .frame(maxWidth: .infinity)
                    .zIndex(2)

                // Fotoğraf
                AsyncImage(url: URL(string: currentNews.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("news_placeholder")
                        .resizable()
                        .scaledToFill()
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.18),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // İçerik kutusu
                VStack(alignment: .leading, spacing: 20) {
                    // Başlık ve tarih
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentNews.description)
                            .font(CustomFont.bold(size: 26))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            Text(currentNews.displayDate)
                                .font(CustomFont.regular(size: 14))
                        .foregroundColor(.gray)
                }
                    }
                    // Açıklama
                    if isLoading {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 16)
                                    .cornerRadius(4)
                            }
                        }
                    } else {
                        Text(currentNews.title)
                            .font(CustomFont.regular(size: 16))
                            .foregroundColor(.primary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    // Kategori bilgisi
                    HStack {
                        Text(currentNews.categoryDisplayName)
                            .font(CustomFont.medium(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.logo)
                            .cornerRadius(12)
                        
                        Spacer()
                    }
        }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.systemBackground).opacity(colorScheme == .dark ? 0.85 : 0.98))
                )
                .padding(.horizontal, 14)
                .padding(.top, -18)
                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadNewsDetail()
        }
    }
    
    // MARK: - Helper Methods
    private var currentNews: AnnouncementData {
        detailedNews ?? news
    }
    
    private func loadNewsDetail() async {
        isLoading = true
        
        do {
            let detailed = try await NewsService.shared.fetchAnnouncementDetail(id: news.id)
            detailedNews = detailed
        } catch {
            print("❌ NewsDetailView: Detay yükleme hatası: \(error)")
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}

// MARK: - Preview
#Preview {
    NewsDetailView(news: AnnouncementData(
        resourceUrn: "announcement:sample123",
        type: "campaign",
        date: "2025-06-09T11:14:11.887Z",
        title: "Yeni Hizmetlerimiz",
        description: "Foşur olarak müşterilerimize daha iyi hizmet verebilmek için yeni hizmetlerimizi duyurmaktan mutluluk duyarız. Artık araçlarınızı daha uygun fiyatlarla ve daha kısa sürede temizleyebileceksiniz.",
        id: "sample123",
        images: ["news_placeholder"],
        state: "created",
        domain: "announcement"
    ))
}
