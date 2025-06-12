import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLoginSheet = false
    @State private var showAddressSheet = false
    @State private var showNotificationsSheet = false
    @State private var showHelpSheet = false
    @State private var showLogoutAlert = false
    @State private var showOrdersSheet = false
    @State private var addresses: [Address] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Profil")
                    .font(CustomFont.bold(size: 28))
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        if !appState.isUserLoggedIn {
                            guestPromptView
                        } else {
                            // Profil Başlığı
                            profileHeader
                            
                            // Menü Öğeleri
                            menuItems
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
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
                onPhoneLogin: {
                    // NavigationManager sistemi kullanılıyor
                },
                hideGuestOption: false
            )
            .presentationDetents([.fraction(0.55)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddressSheet) {
            AddressSelectionView(
                selectedAddress: .constant(nil),
                addresses: addresses,
                onRefresh: {
                    Task {
                        await loadAddresses()
                    }
                },
                mode: .detail
            )
        }
        .sheet(isPresented: $showNotificationsSheet) {
            NotificationsView()
        }
        .sheet(isPresented: $showHelpSheet) {
            HelpView()
        }
        .sheet(isPresented: $showOrdersSheet) {
            OrdersView()
        }
        .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
            Button("İptal", role: .cancel) { }
            Button("Çıkış Yap", role: .destructive) {
                // AuthService logout fonksiyonunu çağır (local storage'ı temizler)
                AuthService.shared.logout()
                
                // AppState'i güncelle
                appState.isUserLoggedIn = false
                appState.currentUser = nil
                appState.tabSelection = .callUs
                
                print("🚪 Kullanıcı başarıyla çıkış yaptı")
            }
        } message: {
            Text("Çıkış yapmak istediğinizden emin misiniz?")
        }
        .onAppear {
            Task {
                await loadAddresses()
            }
        }
    }

    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Profilinizi görüntüleyebilmek için giriş yapmalısınız.")
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

    private var profileHeader: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.logo.opacity(0.8), Color.logo]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                // Shimmer effect
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .opacity(0.7)
                
                // Avatar icon
                Image(systemName: "person.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            .shadow(color: Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // User Info
            VStack(alignment: .leading, spacing: 8) {
                if let user = appState.currentUser {
                    // Full name with sparkle effect
                    HStack(spacing: 8) {
                        Text("\(user.name) \(user.surname)")
                            .font(CustomFont.bold(size: 20))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.logo)
                            .opacity(0.8)
                    }
                    
                    // Phone number
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.logo)
                        
                        Text(user.phoneNumber)
                            .font(CustomFont.medium(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    // Email if available
                    if !user.email.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.logo)
                            
                            Text(user.email)
                                .font(CustomFont.medium(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            ZStack {
                // Main background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.logo.opacity(0.02),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Sparkle decorations
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "sparkle")
                            .font(.system(size: 8))
                            .foregroundColor(.logo.opacity(0.3))
                            .offset(x: -10, y: 10)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "sparkle")
                            .font(.system(size: 6))
                            .foregroundColor(.logo.opacity(0.4))
                            .offset(x: 15, y: -5)
                        Spacer()
                    }
                }
            }
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
        .padding(.horizontal)
    }
    
    private var menuItems: some View {
        VStack(spacing: 16) {
            menuItem(
                icon: "mappin.circle.fill",
                title: "Adreslerim",
                action: { showAddressSheet = true }
            )
            
            menuItem(
                icon: "list.clipboard.fill",
                title: "Siparişlerim",
                action: { showOrdersSheet = true }
            )
            
            menuItem(
                icon: "bell.fill",
                title: "Bildirimler",
                action: { showNotificationsSheet = true }
            )
            
            menuItem(
                icon: "questionmark.circle.fill",
                title: "Yardım",
                action: { showHelpSheet = true }
            )
            
            menuItem(
                icon: "arrow.right.square.fill",
                title: "Çıkış Yap",
                action: { showLogoutAlert = true }
            )
        }
        .padding(.horizontal)
    }
    
    private func menuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        MenuItemButton(icon: icon, title: title, action: action)
    }
    
    private func loadAddresses() async {
        do {
            let fetchedCustomerAddresses = try await CustomerService.shared.getCustomerAddresses()
            
            // CustomerAddress'i legacy Address'e dönüştür
            let convertedAddresses = fetchedCustomerAddresses.map { customerAddress in
                Address(
                    id: customerAddress.id,
                    title: customerAddress.name,
                    fullAddress: customerAddress.formattedAddress,
                    latitude: customerAddress.latitude,
                    longitude: customerAddress.longitude
                )
            }
            
            await MainActor.run {
                self.addresses = convertedAddresses
            }
        } catch {
            print("Adresler yüklenirken hata oluştu: \(error)")
        }
    }
}

struct HelpView: View {
    @State private var expandedFAQIndex: Int? = nil
    
    private let faqs = [
        FAQ(question: "Nasıl hizmet alabilirim?", answer: "Uygulamayı açın, 'Bizi Çağır' sekmesinden aracınızı seçin, adresinizi belirleyin ve istediğiniz hizmeti seçin. Ardından 'Devam Et' butonuna tıklayarak siparişinizi oluşturabilirsiniz."),
        FAQ(question: "Ödeme yöntemlerim neler?", answer: "Kredi kartı, banka kartı ve havale/EFT ile ödeme yapabilirsiniz. Ayrıca uygulama içi cüzdan oluşturarak hızlı ödeme yapabilirsiniz."),
        FAQ(question: "Hizmet ne kadar sürer?", answer: "Standart bir yıkama hizmeti ortalama 30-45 dakika sürer. Detaylı temizlik hizmetleri ise aracın durumuna göre 1-2 saat arasında değişebilir."),
        FAQ(question: "İptal ve iade politikası nedir?", answer: "Hizmet başlamadan önce yapılan iptallerde ücret iadesi yapılır. Hizmet başladıktan sonra yapılan iptallerde iade yapılmaz.")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // İletişim Bilgileri
                    VStack(spacing: 12) {
                        Text("İletişim")
                            .font(CustomFont.bold(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.logo)
                            Text("0850 123 45 67")
                                .font(CustomFont.medium(size: 16))
                        }
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.logo)
                            Text("info@fosur.com")
                                .font(CustomFont.medium(size: 16))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal)
                    
                    // Sıkça Sorulan Sorular
                    VStack(spacing: 12) {
                        Text("Sıkça Sorulan Sorular")
                            .font(CustomFont.bold(size: 18))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                            FAQCard(
                                faq: faq,
                                isExpanded: expandedFAQIndex == index,
                                onTap: {
                                    withAnimation(.spring()) {
                                        if expandedFAQIndex == index {
                                            expandedFAQIndex = nil
                                        } else {
                                            expandedFAQIndex = index
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Yardım")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MenuItemButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: {
            // Basma animasyonu
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            // Action'ı çalıştır
            action()
            
            // Animasyonu sıfırla
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 16) {
                // Icon with subtle glow
                ZStack {
                    Circle()
                        .fill(Color.logo.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.logo)
                }
                
                Text(title)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                    
                    // Shimmer effect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                        .clipped()
                }
            )
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onAppear {
            // Shimmer animasyonu
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
        }
    }
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQCard: View {
    let faq: FAQ
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(faq.question)
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            
            if isExpanded {
                Text(faq.answer)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct NotificationsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Sipariş Bildirimleri", isOn: .constant(true))
                    Toggle("Kampanya Bildirimleri", isOn: .constant(true))
                    Toggle("Sistem Bildirimleri", isOn: .constant(true))
                }
            }
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
