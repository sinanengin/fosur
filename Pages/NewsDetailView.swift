import SwiftUI

struct NewsDetailView: View {
    var news: NewsItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
                    .padding()
            }

            Image(news.image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(12)

            Text(news.title)
                .font(CustomFont.bold(size: 24))
                .padding(.vertical, 8)

            Text(news.description)
                .font(CustomFont.regular(size: 16))

            Spacer()
        }
        .padding()
    }
}
