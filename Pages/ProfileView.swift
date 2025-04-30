import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLoginSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if !appState.isUserLoggedIn {
                    guestPromptView
                } else {
                    profileContent
                }
            }
            .padding(.top)
            .background(Color("BackgroundColor"))
            .sheet(isPresented: $showLoginSheet) {
                AuthSelectionSheetView(
                    onLoginSuccess: {
                        appState.setLoggedInUser()
                        showLoginSheet = false
                    },
                    onGuestContinue: {
                        appState.setGuestUser()
                        showLoginSheet = false
                    },
                    hideGuestOption: false
                )
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Misafir Görünümü
    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Profil bilgilerinizi görüntüleyebilmek için giriş yapmalısınız.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button("Giriş Yap") {
                showLoginSheet = true
            }
            .font(CustomFont.medium(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.logo)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Profil Sayfası (Giriş Yapılmış)
    private var profileContent: some View {
        VStack(spacing: 28) {
            // Başlık
            HStack {
                Text("Profil")
                    .font(CustomFont.bold(size: 28))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            // Profil Fotoğrafı ve İsim
            VStack(spacing: 10) {
                Image("profile_placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.logo, lineWidth: 2))
                    .shadow(radius: 4)

                Spacer().frame(height: 8)

                Text("\(mockUser.name) \(mockUser.surname)")
                    .font(Font.custom("Inter-SemiBold", size: 24))
                    .foregroundColor(.primary)
            }
            .padding(.top, 10)

            // Butonlar
            VStack(spacing: 16) {
                AuthButton(
                    title: "Satın Alımlarım",
                    imageName: "cart",
                    isSystemImage: true
                ) {}
                .frame(maxWidth: .infinity, alignment: .leading)

                AuthButton(
                    title: "Cüzdanım",
                    imageName: "creditcard",
                    isSystemImage: true
                ) {}
                .frame(maxWidth: .infinity, alignment: .leading)

                AuthButton(
                    title: "Yardım Merkezi",
                    imageName: "questionmark.circle",
                    isSystemImage: true
                ) {}
                .frame(maxWidth: .infinity, alignment: .leading)

                AuthButton(
                    title: "Çıkış Yap",
                    imageName: "arrow.right.circle",
                    isSystemImage: true
                ) {
                  //  appState.logout()
                    showLoginSheet = true
                }
                .foregroundColor(.red)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.9), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Mock User
    var mockUser: User {
        appState.currentUser ?? User(
            id: UUID(),
            name: "Sinan",
            surname: "Yıldız",
            email: "sinan@example.com",
            phoneNumber: "05321234567",
            profileImage: nil
        )
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
