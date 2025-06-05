import SwiftUI

struct OnboardingStartView: View {
    @Binding var rootView: RootViewType
    @Binding var isTransitioning: Bool

    @State private var showSheet = false
    @State private var showTermsOfService = false
    @State private var showPrivacyPolicy = false

    @EnvironmentObject var appState: AppState // Kullanıcı durumu için

    var body: some View {
        VStack {
            Image("fosur_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.top, 100)

            Spacer()

            Button(action: {
                showSheet = true
            }) {
                Text("Başlayalım!")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.logo)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 8)

            VStack(spacing: 2) {
                Text("Devam ederek,")
                    .font(.footnote)
                    .foregroundColor(.gray)
                HStack {
                    Button(action: { showTermsOfService = true }) {
                        Text("Kullanıcı Sözleşmesi")
                            .font(.footnote)
                            .underline()
                            .foregroundColor(.gray)
                    }

                    Text("ve")
                        .font(.footnote)
                        .foregroundColor(.gray)

                    Button(action: { showPrivacyPolicy = true }) {
                        Text("Gizlilik Politikası'nı")
                            .font(.footnote)
                            .underline()
                            .foregroundColor(.gray)
                    }
                }
                Text("kabul etmiş olursunuz.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 16)

            Spacer().frame(height: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .ignoresSafeArea()
        .sheet(isPresented: $showSheet) {
            AuthSelectionSheetView(
                onLoginSuccess: {
                    appState.setLoggedInUser()
                    handleTransitionToHome()
                },
                onGuestContinue: {
                    appState.setGuestUser()
                    handleTransitionToHome()
                },
                onPhoneLogin: {
                    // Artık NavigationManager sistemi kullanıyoruz
                    // Bu callback artık kullanılmayacak
                },
                hideGuestOption: false // Misafir seçeneği burada açık olmalı
            )
            .presentationDetents([.fraction(0.55)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTermsOfService) {
            TermsOfServiceView()
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
                .presentationDetents([.medium, .large])
        }
        .fullScreenCover(item: $appState.navigationManager.presentedFullScreenCover) { destination in
            switch destination {
            case .phoneLogin:
                PhoneLoginView()
                    .environmentObject(appState)
            default:
                EmptyView()
            }
        }
    }

    private func handleTransitionToHome() {
        showSheet = false

        // Sheet kapandıktan sonra geçiş yapalım:
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
