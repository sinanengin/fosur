import SwiftUI

struct ButtonSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                print("Hesap oluştur butonuna tıklandı")
            }) {
                Text("Hesap Oluştur")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.logo)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }

            Button(action: {
                print("Zaten bir hesabım var butonuna tıklandı")
            }) {
                Text("Zaten Bir Hesabım Var")
                    .font(.headline)
                    .foregroundColor(.logo)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.logo, lineWidth: 2)
                    )
            }
        }
        .padding(.horizontal, 24)
    }
}



#Preview {
    ButtonSection()
}
