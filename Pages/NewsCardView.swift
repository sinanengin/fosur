import SwiftUI

struct NewsCardView: View {
    var imageName: String
    var title: String
    var description: String
    var type: NewsType

    var body: some View {
        VStack(alignment: .leading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .cornerRadius(8, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(CustomFont.bold(size: 16))
                    .foregroundColor(.primaryText)

                Text(description)
                    .font(CustomFont.regular(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
        }
        .background(Color("backgroundColor"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

enum NewsType {
    case campaign
    case announcement
}
