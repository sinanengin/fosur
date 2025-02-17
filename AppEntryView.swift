import SwiftUI

enum RootViewType {
    case onboarding
    case home
}

struct AppEntryView: View {
    @State private var rootView: RootViewType = .onboarding
    @State private var isTransitioning = false // Geçiş sürecini kontrol ediyoruz

    var body: some View {
        ZStack {
            if rootView == .onboarding {
                OnboardingStartView(rootView: $rootView, isTransitioning: $isTransitioning)
                    .opacity(isTransitioning ? 0 : 1)
                    .animation(.easeInOut(duration: 0.4), value: isTransitioning)
            } else if rootView == .home {
                HomeView()
                    .opacity(isTransitioning ? 0 : 1)
                    .animation(.easeInOut(duration: 0.4), value: isTransitioning)
            }
        }
        .transition(.opacity)
    }
}
