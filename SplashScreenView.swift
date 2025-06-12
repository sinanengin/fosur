import SwiftUI

struct SplashScreenView: View {
    @StateObject private var appState = AppState()
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            if appState.isLoadingAuth {
                // Splash screen - auto-login kontrolü yapılırken
            VStack {
                    Image("fosur_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                        .opacity(opacity)
                    
                    // Loading indicator
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.logo)
                        
                        Text("Yükleniyor...")
                            .font(CustomFont.regular(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        opacity = 0.8
                    }
                }
            } else {
                // Auto-login kontrolü tamamlandı
                if appState.isUserLoggedIn {
                    // Kullanıcı zaten giriş yapmış, direkt ana sayfaya git
                    HomeView()
                        .environmentObject(appState)
                        .transition(.opacity)
                } else {
                    // Kullanıcı giriş yapmamış, onboarding'e git
                    AppEntryView()
                        .environmentObject(appState)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.isLoadingAuth)
        .animation(.easeInOut(duration: 0.5), value: appState.isUserLoggedIn)
    }
}
