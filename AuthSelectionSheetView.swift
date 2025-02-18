import SwiftUI

struct AuthSelectionSheetView: View {
    var onLoginSuccess: () -> Void

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
                AuthButton(title: "Apple ile devam et   ", imageName: "applelogo", isSystemImage: false) {
                    onLoginSuccess()
                }

                AuthButton(title: "Google ile devam et ", imageName: "googlelogo", isSystemImage: false) {
                    onLoginSuccess()
                }

                AuthButton(title: "Telefon ile devam et", imageName: "phone.fill", isSystemImage: true) {
                    onLoginSuccess()
                }
            }
            .padding(.horizontal, 24)

            DividerWithOr()

            Button(action: {
                onLoginSuccess()
            }) {
                Text("Misafir olarak devam et")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 0)
            }
            .padding(.bottom, 16)

            Spacer()
        }
        .padding(.top, 8)
        .background(Color("BackgroundColor"))
    }
}
