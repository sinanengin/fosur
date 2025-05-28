import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLoginSheet = false

    var body: some View {
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
        ScrollView {
            VStack(spacing: 24) {
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
                VStack(spacing: 12) {
                    Image("profile_placeholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.logo, lineWidth: 2))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

                    Text("\(mockUser.name) \(mockUser.surname)")
                        .font(CustomFont.semiBold(size: 20))
                        .foregroundColor(.primary)
                }
                .padding(.top, 10)

                // Ana Menü Butonları
                VStack(spacing: 16) {
                    AuthButton(
                        title: "Sipariş Geçmişi",
                        imageName: "clock.arrow.circlepath",
                        isSystemImage: true
                    ) {}
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                    AuthButton(
                        title: "Adreslerim",
                        imageName: "mappin.circle",
                        isSystemImage: true
                    ) {}
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)

                    AuthButton(
                        title: "Cüzdanım",
                        imageName: "creditcard",
                        isSystemImage: true
                    ) {}
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)

                // Alt Butonlar
                HStack(spacing: 16) {
                    Button {
                        // Yardım merkezi aksiyonu
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Yardım")
                        }
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }

                    Button {
                        showLoginSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle")
                            Text("Çıkış")
                        }
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.2))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.8, green: 0.2, blue: 0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
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
