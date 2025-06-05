import SwiftUI

struct NewsDetailView: View {
    var news: NewsItem
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

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
                Image(news.image)
                    .resizable()
                    .scaledToFill()
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
                        Text(news.title)
                            .font(CustomFont.bold(size: 26))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            Text(news.date)
                                .font(CustomFont.regular(size: 14))
                        .foregroundColor(.gray)
                }
                    }
                    // Açıklama
                    Text(news.description)
                        .font(CustomFont.regular(size: 16))
                        .foregroundColor(.primary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                    // Detaylar
                    if let additionalInfo = news.additionalInfo {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Detaylar")
                                .font(CustomFont.semiBold(size: 17))
                                .foregroundColor(.primary)
                            ForEach(additionalInfo, id: \.self) { info in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.logo)
                                        .padding(.top, 7)
                                    Text(info)
                                        .font(CustomFont.regular(size: 15))
                                        .foregroundColor(.primary)
                                        .lineSpacing(3)
                                }
                            }
                        }
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
    }
}

// MARK: - Preview
#Preview {
    NewsDetailView(news: NewsItem(
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
    ))
}
