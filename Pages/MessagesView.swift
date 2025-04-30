import SwiftUI

struct MessagesView: View {
    @State private var selectedChat: ChatPreview?
    @State private var isShowingDetail = false

    let messages: [ChatPreview] = [
        ChatPreview(id: UUID(), senderName: "Canlı Destek", senderTitle: "Foşur Destek Ekibi", lastMessage: "Nasıl yardımcı olabilirim?", time: "13:00"),
        ChatPreview(id: UUID(), senderName: "Temizlik Ekibi", senderTitle: "Foşur Temizlik Ekibi", lastMessage: "Temizlik tamamlandı, iyi günler!", time: "12:45"),
        ChatPreview(id: UUID(), senderName: "Müşteri Hizmetleri", senderTitle: "Foşur Hizmetleri", lastMessage: "Size dönüş yapacağız.", time: "11:30")
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mesajlar")
                    .font(CustomFont.bold(size: 26))
                    .padding(.horizontal)
                    .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            Button {
                                selectedChat = message
                                isShowingDetail = true
                            } label: {
                                ChatCardView(message: message)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color("BackgroundColor"))
            .navigationDestination(isPresented: $isShowingDetail) {
                if let chat = selectedChat {
                    ChatDetailView(chat: chat) {
                        selectedChat = nil
                        isShowingDetail = false
                    }
                }
            }
        }
    }
}
