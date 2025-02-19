import SwiftUI

struct NewsCardView: View {
    var news: NewsItem

    var body: some View {
        VStack(alignment: .leading) {
            Image(news.image)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .cornerRadius(8, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                Text(news.title)
                    .font(CustomFont.bold(size: 16))
                    .foregroundColor(.primaryText)

                Text(news.description)
                    .font(CustomFont.regular(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
