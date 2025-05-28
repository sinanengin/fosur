import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var appState: AppState
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

                if !appState.isUserLoggedIn {
                    VStack(spacing: 20) {
                        Spacer()
                        Text("Mesajlarınızı görebilmek için önce giriş yapmalısınız.")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button {
                            appState.showAuthSheet = true
                        } label: {
                            Text("Giriş Yap")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.logo)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                } else {
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
            .sheet(isPresented: $appState.showAuthSheet) {
                AuthSelectionSheetView(
                    onLoginSuccess: {
                        appState.setLoggedInUser()
                        appState.showAuthSheet = false
                    },
                    onGuestContinue: {
                        appState.setGuestUser()
                        appState.showAuthSheet = false
                    },
                    hideGuestOption: false
                )
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}
