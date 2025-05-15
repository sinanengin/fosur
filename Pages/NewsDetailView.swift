import SwiftUI

struct NewsDetailView: View {
    var news: NewsItem
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)

            Image(news.image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(12)

            Text(news.title)
                .font(CustomFont.bold(size: 24))

            Text(news.description)
                .font(CustomFont.regular(size: 16))

            Spacer()
        }
        .padding()
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}
