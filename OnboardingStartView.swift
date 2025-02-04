import SwiftUI

struct OnboardingStartView: View {
    @State private var showTermsPopup = false
    @State private var showPrivacyPopup = false

    var body: some View {
        VStack {
            Spacer().frame(height: 60)

            LogoView() // Logo buraya geldi

            Spacer()

            ButtonSection() // Butonlar artık ayrı dosyada

            TermsText(showTermsPopup: $showTermsPopup, showPrivacyPopup: $showPrivacyPopup) // Metin bileşeni

            Spacer().frame(height: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .ignoresSafeArea()
        .overlay(
            showTermsPopup ? TermsPopupView(isPresented: $showTermsPopup, title: "Kullanım Şartları", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...Lorem ipsum dolor sit amet, consectetur adipiscing elit...") : nil
        )
        .overlay(
            showPrivacyPopup ? TermsPopupView(isPresented: $showPrivacyPopup, title: "Gizlilik Politikası", content: "Vestibulum ante ipsum primis in faucibus orci luctus...") : nil
        )
    }
}


#Preview {
    OnboardingStartView()
}
