import SwiftUI

enum RootViewType {
    case onboarding
    case home
}

struct AppEntryView: View {
    @StateObject private var appState = AppState()
    @State private var rootView: RootViewType = .onboarding
    @State private var isTransitioning = false // Geçiş sürecini kontrol ediyoruz

    var body: some View {
        ZStack {
            if rootView == .onboarding {
                OnboardingStartView(rootView: $rootView, isTransitioning: $isTransitioning)
                    .opacity(isTransitioning ? 0 : 1)
                    .animation(.easeInOut(duration: 0.4), value: isTransitioning)
                    .environmentObject(appState)
            } else if rootView == .home {
                HomeView()
                    .opacity(isTransitioning ? 0 : 1)
                    .animation(.easeInOut(duration: 0.4), value: isTransitioning)
                    .environmentObject(appState)
            }
        }
        .transition(.opacity)
        .onChange(of: appState.isUserLoggedIn) { oldValue, newValue in
            // Kullanıcı giriş yaptıysa ve onboarding'den geldiyse home'a geç
            if newValue && appState.isFromOnboarding {
                handleTransitionToHome()
            }
        }
    }
    
    private func handleTransitionToHome() {
        appState.isFromOnboarding = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                isTransitioning = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    rootView = .home
                    isTransitioning = false
                }
            }
        }
    }
}
