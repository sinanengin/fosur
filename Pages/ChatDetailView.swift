import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let chat: Chat
    
    var body: some View {
        VStack(spacing: 0) {
            // Mesaj Listesi
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .onChange(of: messages.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }
            
            // Mesaj Giriş Alanı
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // Fotoğraf Ekleme Butonu
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.logo)
                    }
                    
                    // Mesaj Giriş Alanı
                    TextField("Mesajınızı yazın...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                    
                    // Gönder Butonu
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .gray : .logo)
                    }
                    .disabled(messageText.isEmpty || isLoading)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
            }
        }
        .navigationTitle(chat.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "phone")
                        .foregroundColor(.logo)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                handleImageSelection(image)
            }
        }
        .onAppear {
            loadMessages()
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
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
    }
    
    private func loadMessages() {
        // Test için örnek mesajlar
        messages = [
            ChatMessage(
                id: UUID().uuidString,
                chatId: chat.id,
                senderId: "support",
                content: "Merhaba, nasıl yardımcı olabilirim?",
                imageUrl: nil,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: true,
                type: .text
            ),
            ChatMessage(
                id: UUID().uuidString,
                chatId: chat.id,
                senderId: "current_user",
                content: "Aracımı yıkatmak istiyorum.",
                imageUrl: nil,
                timestamp: Date().addingTimeInterval(-3500),
                isRead: true,
                type: .text
            ),
            ChatMessage(
                id: UUID().uuidString,
                chatId: chat.id,
                senderId: "support",
                content: "Tabii ki, hangi hizmeti tercih edersiniz?",
                imageUrl: nil,
                timestamp: Date().addingTimeInterval(-3400),
                isRead: true,
                type: .text
            )
        ]
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = ChatMessage(
            id: UUID().uuidString,
            chatId: chat.id,
            senderId: "current_user",
            content: messageText,
            imageUrl: nil,
            timestamp: Date(),
            isRead: false,
            type: .text
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Simüle edilmiş yanıt
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = ChatMessage(
                id: UUID().uuidString,
                chatId: self.chat.id,
                senderId: "support",
                content: "Mesajınız alındı, en kısa sürede size dönüş yapacağız.",
                imageUrl: nil,
                timestamp: Date(),
                isRead: false,
                type: .text
            )
            self.messages.append(response)
        }
    }
    
    private func handleImageSelection(_ image: UIImage) {
        if let _ = image.jpegData(compressionQuality: 0.8) {
            let newMessage = ChatMessage(
                id: UUID().uuidString,
                chatId: chat.id,
                senderId: "current_user",
                content: "",
                imageUrl: nil,
                timestamp: Date(),
                isRead: false,
                type: .image
            )
            messages.append(newMessage)
            
            // Simüle edilmiş yanıt
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let response = ChatMessage(
                    id: UUID().uuidString,
                    chatId: self.chat.id,
                    senderId: "support",
                    content: "Fotoğrafınız alındı, inceleyip size dönüş yapacağız.",
                    imageUrl: nil,
                    timestamp: Date(),
                    isRead: false,
                    type: .text
                )
                self.messages.append(response)
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.senderId == "current_user" {
                Spacer()
            }
            
            VStack(alignment: message.senderId == "current_user" ? .trailing : .leading, spacing: 4) {
                if message.type == .image, let imageUrl = message.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 150)
                    }
                }
                
                if message.type == .text {
                    Text(message.content)
                        .font(CustomFont.regular(size: 16))
                        .foregroundColor(message.senderId == "current_user" ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(message.senderId == "current_user" ? Color.logo : Color.gray.opacity(0.1))
                        )
                }
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(CustomFont.regular(size: 12))
                    .foregroundColor(.secondary)
            }
            
            if message.senderId != "current_user" {
                Spacer()
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(chat: Chat(
            id: "preview_chat",
            userId: "preview_user",
            title: "Destek",
            lastMessage: "Merhaba, nasıl yardımcı olabilirim?",
            timestamp: Date(),
            isRead: true,
            participants: ["preview_user", "support"],
            type: .support
        ))
    }
}
