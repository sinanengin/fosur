import SwiftUI

struct MessagesView: View {
    @EnvironmentObject var appState: AppState
    @State private var chats: [Chat] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mesajlar")
                    .font(CustomFont.bold(size: 28))
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                Group {
                    if !appState.isUserLoggedIn {
                        guestPromptView
                    } else if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                    } else if chats.isEmpty {
                        emptyStateView
                    } else {
                        chatListView
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Hata", isPresented: .constant(errorMessage != nil)) {
            Button("Tamam") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
        .onAppear {
            loadChats()
        }
    }
    
    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Mesajlarınızı görüntüleyebilmek için giriş yapmalısınız.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button("Giriş Yap") {
                // Giriş sayfasını göster
            }
            .font(CustomFont.medium(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.logo)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "message")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Henüz mesajınız bulunmuyor")
                .font(CustomFont.medium(size: 18))
                .foregroundColor(.gray)
        }
    }
    
    private var chatListView: some View {
        List(chats) { chat in
            NavigationLink(destination: ChatDetailView(chat: chat)) {
                ChatRow(chat: chat)
            }
        }
        .listStyle(.plain)
    }
    
    private func loadChats() {
        // Test için örnek sohbetler
        chats = [
            Chat(
                id: "1",
                userId: "current_user",
                title: "Destek",
                lastMessage: "Merhaba, nasıl yardımcı olabilirim?",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: true,
                participants: ["current_user", "support"],
                type: .support
            ),
            Chat(
                id: "2",
                userId: "current_user",
                title: "Araç Yıkama",
                lastMessage: "Aracınız yıkama için hazır.",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                participants: ["current_user", "service"],
                type: .service
            )
        ]
    }
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Profil Resmi
            Circle()
                .fill(Color.logo.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: chat.type == .support ? "person.fill" : "car.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.logo)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.title)
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(chat.timestamp.formatted(.relative(presentation: .named)))
                        .font(CustomFont.regular(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Text(chat.lastMessage)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
        .opacity(chat.isRead ? 1 : 0.8)
    }
}

#Preview {
    MessagesView()
        .environmentObject(AppState())
}
