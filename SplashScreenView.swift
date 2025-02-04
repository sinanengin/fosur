import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity: Double = 1.0 // Opaklık için state ekledik
    
    var body: some View {
        if isActive {
            SignUpView() // Onboarding ekranına geçiş
        } else {
            VStack {
                Image("fosur_logo") // Logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(opacity) // Opaklık değişimi uygulanacak
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            withAnimation(.easeOut(duration: 0.5)) { // Hızlı ve smooth yok oluş
                                opacity = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isActive = true
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.background(Color("Background")) // Arka plan rengi temaya uygun olacak
        }
    }
}
