import SwiftUI

struct AuthSelectionSheetView: View {
    var onLoginSuccess: () -> Void
    var onGuestContinue: () -> Void
    var onPhoneLogin: () -> Void
    var hideGuestOption: Bool

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var isProcessing = false // Çoklu tıklama koruması

    var body: some View {
        VStack(spacing: 16) {
            Text("Başlayalım!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.logo)
                .padding(.top, 16)

            Text("Hesap oluşturmak veya oturum açmak için bir yöntem seç")
                .font(.subheadline)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                AuthButton(title: "Apple ile devam et", imageName: "applelogo", isSystemImage: false) {
                    handleAppleLogin()
                }
                AuthButton(title: "Google ile devam et", imageName: "googlelogo", isSystemImage: false) {
                    handleGoogleLogin()
                }
                AuthButton(title: "Telefon ile devam et", imageName: "phone.fill", isSystemImage: true) {
                    handlePhoneLogin()
                }
            }
            .padding(.horizontal, 24)
            .disabled(isProcessing) // İşlem sırasında butonları devre dışı bırak

            if !hideGuestOption {
                DividerWithOr()

                Button(action: {
                    handleGuestContinue()
                }) {
                    Text("Misafir olarak devam et")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .disabled(isProcessing)
            }

            Spacer()
        }
        .padding(.top, 8)
        .background(Color("BackgroundColor"))
    }

    private func handleAppleLogin() {
        guard !isProcessing else { return }
        isProcessing = true
        
        print("Apple ile devam et tıklandı")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            handleLoginSuccess()
            isProcessing = false
        }
    }
    
    private func handleGoogleLogin() {
        guard !isProcessing else { return }
        isProcessing = true
        
        print("Google ile devam et tıklandı")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            handleLoginSuccess()
            isProcessing = false
        }
    }
    
    private func handlePhoneLogin() {
        guard !isProcessing else { 
            print("⚠️ handlePhoneLogin: Zaten işleniyor, çıkıyor...")
            return 
        }
        
        isProcessing = true
        print("📱 Telefon ile devam et tıklandı - handlePhoneLogin başladı")
        
        // Önce misafir olarak giriş yap
        onGuestContinue()
        
        // Sheet'i kapat ve telefon giriş ekranını aç
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss()
            
            // Sheet tamamen kapandıktan sonra telefon giriş ekranını aç
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.appState.navigationManager.presentFullScreen(.phoneLogin)
                self.isProcessing = false
                print("📱 handlePhoneLogin tamamlandı, isProcessing = false")
            }
        }
    }

    private func handleLoginSuccess() {
        onLoginSuccess()
        dismiss()
    }

    private func handleGuestContinue() {
        guard !isProcessing else { return }
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            onGuestContinue()
            dismiss()
            isProcessing = false
        }
    }
}
