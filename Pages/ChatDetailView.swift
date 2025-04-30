import SwiftUI

struct ChatDetailView: View {
    let chat: ChatPreview
    var onDismiss: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var newMessage = ""
    @State private var chatMessages: [ChatBubble] = [
        ChatBubble(content: "Merhaba, nasıl yardımcı olabilirim?", isSentByUser: false),
        ChatBubble(content: "Temizlik hizmeti hakkında bilgi alabilir miyim?", isSentByUser: true)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button {
                    dismiss()
                    onDismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(8)
                }

                Image("profile_placeholder")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(chat.senderName)
                        .font(CustomFont.medium(size: 16))
                    Text(chat.senderTitle)
                        .font(CustomFont.regular(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .background(Color.white.shadow(radius: 2))

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(chatMessages) { bubble in
                            HStack {
                                if bubble.isSentByUser {
                                    Spacer()
                                }

                                Text(bubble.content)
                                    .padding(12)
                                    .background(bubble.isSentByUser ? Color.logo.opacity(0.2) : Color.gray.opacity(0.1))
                                    .foregroundColor(.black)
                                    .cornerRadius(16)
                                    .frame(maxWidth: 250, alignment: bubble.isSentByUser ? .trailing : .leading)

                                if !bubble.isSentByUser {
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .onChange(of: chatMessages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(chatMessages.last?.id)
                    }
                }
            }

            // Input bar
            HStack(spacing: 10) {
                TextField("Mesaj yaz...", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.logo)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white.shadow(radius: 2))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }

    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        chatMessages.append(ChatBubble(content: newMessage, isSentByUser: true))
        newMessage = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            chatMessages.append(ChatBubble(content: "Mesajınız alındı. En kısa sürede yanıtlayacağız.", isSentByUser: false))
        }
    }
}
