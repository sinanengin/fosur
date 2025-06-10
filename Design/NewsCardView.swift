import SwiftUI

struct NewsCardView: View {
    var news: AnnouncementData

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: news.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image("news_placeholder")
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(8, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(news.categoryDisplayName)
                        .font(CustomFont.medium(size: 10))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.logo)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text(news.displayDate)
                        .font(CustomFont.regular(size: 10))
                        .foregroundColor(.gray)
                }
                
                Text(news.description)
                    .font(CustomFont.bold(size: 16))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)

                Text(news.title)
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
