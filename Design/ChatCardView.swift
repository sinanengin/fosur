import SwiftUI

struct ChatCardView: View {
    let message: ChatPreview

    var body: some View {
        HStack(spacing: 12) {
            Image("profile_placeholder")
                .resizable()
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(message.senderName)
                    .font(CustomFont.medium(size: 15))
                Text(message.lastMessage)
                    .font(CustomFont.regular(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(message.time)
                .font(CustomFont.regular(size: 12))
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                .background(Color.white.cornerRadius(12))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
