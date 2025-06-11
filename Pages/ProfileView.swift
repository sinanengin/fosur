import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLoginSheet = false
    @State private var showAddressSheet = false
    @State private var showPaymentSheet = false
    @State private var showNotificationsSheet = false
    @State private var showHelpSheet = false
    @State private var showLogoutAlert = false
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
                }
            )
        }
        .sheet(isPresented: $showPaymentSheet) {
            PaymentMethodsView()
        }
        .sheet(isPresented: $showNotificationsSheet) {
            NotificationsView()
        }
        .sheet(isPresented: $showHelpSheet) {
            HelpView()
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
        VStack(spacing: 16) {
            if let user = appState.currentUser {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.logo)
                
                Text(user.name)
                    .font(CustomFont.bold(size: 24))
                    .foregroundColor(.primary)
                
                Text(user.phoneNumber)
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
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
                icon: "creditcard.fill",
                title: "Ödeme Yöntemlerim",
                action: { showPaymentSheet = true }
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
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.logo)
                    .frame(width: 32)
                
                Text(title)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            )
        }
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

struct PaymentMethodsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "creditcard.fill")
                            .foregroundColor(.logo)
                        Text("Kredi Kartı")
                        Spacer()
                        Text("**** **** **** 1234")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.logo)
                        Text("Banka Kartı")
                        Spacer()
                        Text("**** **** **** 5678")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Kayıtlı Kartlar")
                }
                
                Section {
                    Button(action: {}) {
                        Label("Yeni Kart Ekle", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Ödeme Yöntemleri")
            .navigationBarTitleDisplayMode(.inline)
        }
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
