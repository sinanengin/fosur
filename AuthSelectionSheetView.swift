import SwiftUI

struct AuthSelectionSheetView: View {
    var onLoginSuccess: () -> Void
    var onGuestContinue: () -> Void
    var hideGuestOption: Bool

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var showPhoneLogin = false

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
                    handleLoginSuccess()
                }
                AuthButton(title: "Google ile devam et", imageName: "googlelogo", isSystemImage: false) {
                    handleLoginSuccess()
                }
                AuthButton(title: "Telefon ile devam et", imageName: "phone.fill", isSystemImage: true) {
                    showPhoneLogin = true
                }
            }
            .padding(.horizontal, 24)

            if !hideGuestOption {
                DividerWithOr()

                Button(action: {
                    handleGuestContinue()
                }) {
                    Text("Misafir olarak devam et")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding(.top, 8)
        .background(Color("BackgroundColor"))
        .sheet(isPresented: $showPhoneLogin) {
            PhoneLoginView()
                .environmentObject(appState)
        }
    }

    private func handleLoginSuccess() {
        onLoginSuccess()
        dismiss()
    }

    private func handleGuestContinue() {
        onGuestContinue()
        dismiss()
    }
}
