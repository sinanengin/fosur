import SwiftUI

struct TermsText: View {
    @Binding var showTermsPopup: Bool
    @Binding var showPrivacyPopup: Bool

    var body: some View {
        VStack {
            Text("Devam ederek Foşur'un")
                .foregroundColor(.gray)

            HStack(spacing: 5) {
                Text("Kullanım Şartları")
                    .foregroundColor(.black)
                    .underline()
                    .onTapGesture {
                        showTermsPopup = true
                    }

                Text("ve")
                    .foregroundColor(.gray)

                Text("Gizlilik Politikası")
                    .foregroundColor(.black)
                    .underline()
                    .onTapGesture {
                        showPrivacyPopup = true
                    }
            }

            Text(" 'nı kabul etmiş olursunuz.")
                .foregroundColor(.gray)
        }
        .font(.footnote)
        .padding(.top, 10)
        .padding(.horizontal, 24)
    }
}
