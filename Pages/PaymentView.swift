import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var appState: AppState
    @State private var savedCards: [PaymentCard] = []
    @State private var selectedCard: PaymentCard?
    @State private var isLoading = true
    @State private var showAddCardSheet = false
    
    // Payment flow states
    @State private var isProcessingPayment = false
    @State private var paymentCompleted = false
    @State private var isCreatingOrder = false
    @State private var orderCreated = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var orderCreationAttempted = false // Tek seferlik gönderim için
    
    private var order: LocalOrder? {
        appState.navigationManager.currentOrder
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                if orderCreated {
                    // Success State
                    successView
                } else if isCreatingOrder {
                    // Creating Order State
                    creatingOrderView
                } else if paymentCompleted {
                    // Payment Success State
                    paymentSuccessView
                } else {
                    // Payment Selection State
                    paymentSelectionView
                }
            }
            .background(Color("BackgroundColor"))
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddCardSheet) {
                AddCardView { newCard in
                    savedCards.append(newCard)
                    selectedCard = newCard
                }
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadSavedCards()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            if !orderCreated {
                Button(action: {
                    if paymentCompleted || isCreatingOrder {
                        // Ödeme sonrası geri dönüş - OrderSummary'ye
                        resetPaymentFlow()
                    } else {
                        // Normal geri dönüş
                        DispatchQueue.main.async {
                            appState.showPayment = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appState.showOrderSummary = true
                        }
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
            } else {
                Color.clear
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(orderCreated ? "Sipariş Oluşturuldu" : (paymentCompleted || isCreatingOrder) ? "İşlem Devam Ediyor" : "Ödeme")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Boş alan - buton boyutu için
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Color("BackgroundColor"))
    }
    
    private var emptyCardsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Henüz kayıtlı kartınız yok")
                .font(CustomFont.medium(size: 16))
                .foregroundColor(.secondary)
            
            Text("Ödeme yapabilmek için bir kart ekleyin")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showAddCardSheet = true
            }) {
                Text("İlk Kartını Ekle")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.logo)
                    .cornerRadius(12)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private var paymentButton: some View {
        Button(action: {
            processPayment()
        }) {
            HStack {
                if isProcessingPayment {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("İşleniyor...")
                        .font(CustomFont.bold(size: 18))
                } else {
                    Text("Ödemeyi Yap")
                        .font(CustomFont.bold(size: 18))
                    
                    if let order = order {
                        Text("(\(String(format: "%.2f ₺", order.grandTotal)))")
                            .font(CustomFont.bold(size: 16))
                    }
                    
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isProcessingPayment ? Color.gray : Color.logo)
            .cornerRadius(16)
            .shadow(color: isProcessingPayment ? Color.clear : Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isProcessingPayment)
    }
    
    private func loadSavedCards() {
        isLoading = true
        
        // API çağrısını simüle et
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            savedCards = generateMockCards()
            if !savedCards.isEmpty {
                selectedCard = savedCards.first { $0.isDefault } ?? savedCards.first
            }
            isLoading = false
        }
    }
    
    private func generateMockCards() -> [PaymentCard] {
        return mockPaymentCards
    }
    
    private func processPayment() {
        guard let selectedCard = selectedCard,
              let order = order else { return }
        
        isProcessingPayment = true
        
        // Apple Pay benzeri ödeme simülasyonu
        print("💳 Ödeme işlemi başlatılıyor...")
        print("🏦 Kart: \(selectedCard.maskedCardNumber)")
        print("💰 Tutar: \(order.grandTotal)")
        
        // 2 saniye ödeme işlemi simülasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessingPayment = false
            paymentCompleted = true
            print("✅ Ödeme başarılı!")
        }
    }
    
    // MARK: - Different View States
    
    private var paymentSelectionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Başlık
                VStack(spacing: 8) {
                    Text("Ödeme")
                        .font(CustomFont.bold(size: 28))
                        .foregroundColor(.primary)
                    
                    if let order = order {
                        Text("Toplam: \(String(format: "%.2f ₺", order.grandTotal))")
                            .font(CustomFont.bold(size: 20))
                            .foregroundColor(.logo)
                    }
                }
                .padding(.top, 20)
                
                // Kayıtlı Kartlar
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Kayıtlı Kartlar")
                            .font(CustomFont.bold(size: 20))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddCardSheet = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Yeni Kart")
                                    .font(CustomFont.medium(size: 14))
                            }
                            .foregroundColor(.logo)
                        }
                    }
                    
                    if isLoading {
                        ProgressView("Kartlar yükleniyor...")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if savedCards.isEmpty {
                        emptyCardsView
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(savedCards) { card in
                                PaymentCardView(
                                    card: card,
                                    isSelected: selectedCard?.id == card.id,
                                    onSelect: {
                                        selectedCard = card
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Ödeme Yap Butonu
                if selectedCard != nil {
                    paymentButton
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
            }
        }
    }
    
    private var paymentSuccessView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 12) {
                    Text("Ödeme Başarılı!")
                        .font(CustomFont.bold(size: 24))
                        .foregroundColor(.primary)
                    
                    if let order = order {
                        Text("\(String(format: "%.2f ₺", order.grandTotal)) tutarında ödemeniz alınmıştır.")
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("Siparişiniz oluşturuluyor...")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Loading indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .logo))
                        .scaleEffect(1.2)
                        .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .onAppear {
            // Sadece bir kez sipariş oluşturmayı dene
            if !orderCreationAttempted {
                orderCreationAttempted = true
                createOrderAfterPayment()
            }
        }
    }
    
    private var creatingOrderView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Loading Animation
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .logo))
                    .scaleEffect(2.0)
                
                VStack(spacing: 12) {
                    Text("Sipariş Oluşturuluyor")
                        .font(CustomFont.bold(size: 24))
                        .foregroundColor(.primary)
                    
                    Text("Lütfen bekleyiniz...")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.secondary)
                    
                    if let order = order {
                        Text("Sipariş Tutarı: \(String(format: "%.2f ₺", order.grandTotal))")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var successView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.logo.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.logo)
                }
                
                VStack(spacing: 12) {
                    Text("Sipariş Oluşturuldu!")
                        .font(CustomFont.bold(size: 28))
                        .foregroundColor(.primary)
                    
                    Text("Siparişiniz başarıyla oluşturuldu ve işleme alınmıştır.")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Siparişlerim sayfasından takip edebilirsiniz.")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    // Siparişlerim sayfasına git
                    goToOrders()
                }) {
                    Text("Siparişlerimi Görüntüle")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.logo)
                        .cornerRadius(16)
                        .shadow(color: Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    // Ana sayfaya dön
                    goToHome()
                }) {
                    Text("Ana Sayfaya Dön")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.logo)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.logo, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Helper Functions
    
    private func createOrderAfterPayment() {
        guard let currentOrder = appState.navigationManager.currentOrder,
              let customerId = AuthService.shared.getCurrentCustomerId() else {
            errorMessage = "Sipariş bilgileri eksik"
            showError = true
            return
        }
        
        isCreatingOrder = true
        
        Task {
            do {
                // Önce bu araç için aktif sipariş var mı kontrol et
                let vehicleId = currentOrder.vehicle.apiId ?? currentOrder.vehicle.id.uuidString
                let hasActiveOrder = try await OrderService.shared.hasActiveOrderForVehicle(
                    customerId: customerId, 
                    vehicleId: vehicleId
                )
                
                if hasActiveOrder {
                    throw NSError(domain: "OrderError", code: 409, userInfo: [NSLocalizedDescriptionKey: "Bu araç için hali hazırda aktif bir siparişiniz bulunuyor. Mevcut siparişinizi tamamladıktan sonra yeni sipariş verebilirsiniz."])
                }
                
                // API bağlantısını test et (ama başarısız olsa bile devam et)
                let isConnected = await OrderService.shared.testConnection()
                if !isConnected {
                    print("⚠️ Health check başarısız ama sipariş oluşturmayı deneyeceğim")
                }
                
                // CustomerService'den full adres bilgilerini al
                let customerAddresses = try await CustomerService.shared.getCustomerAddresses()
                guard let fullAddress = customerAddresses.first(where: { $0.id == currentOrder.address.id }) else {
                    throw NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Adres bulunamadı"])
                }
                
                // Service'leri ServiceData'ya dönüştür
                let serviceDataList = currentOrder.selectedServices.map { service in
                    service.toServiceData()
                }
                
                // Rezervasyon tarihini oluştur
                let calendar = Calendar.current
                let timeComponents = currentOrder.serviceTime.split(separator: ":")
                guard timeComponents.count == 2,
                      let hour = Int(timeComponents[0]),
                      let minute = Int(timeComponents[1]) else {
                    throw NSError(domain: "OrderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Geçersiz saat formatı"])
                }
                
                var reservationDate = currentOrder.serviceDate
                reservationDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: reservationDate) ?? reservationDate
                
                // Sipariş oluştur
                let createdOrder = try await OrderService.shared.createOrder(
                    address: fullAddress,
                    car: currentOrder.vehicle,
                    reservationTime: reservationDate,
                    washPackages: serviceDataList,
                    customerId: customerId
                )
                
                print("✅ Sipariş başarıyla oluşturuldu: \(createdOrder.id)")
                
                await MainActor.run {
                    isCreatingOrder = false
                    orderCreated = true
                }
                
            } catch {
                print("❌ Sipariş oluştururken hata: \(error)")
                await MainActor.run {
                    isCreatingOrder = false
                    errorMessage = error.localizedDescription
                    showError = true
                    
                    // 3 saniye sonra ana sayfaya dön
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.goToHome()
                    }
                }
            }
        }
    }
    
    private func resetPaymentFlow() {
        isProcessingPayment = false
        paymentCompleted = false
        isCreatingOrder = false
        orderCreated = false
        orderCreationAttempted = false
        
        DispatchQueue.main.async {
            appState.showPayment = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            appState.showOrderSummary = true
        }
    }
    
    private func goToOrders() {
        // Order flow'u temizle
        appState.navigationManager.clearOrderFlow()
        appState.navigationManager.hideAllOrderScreens(appState: appState)
        
        // Profile tab'ına geç (siparişler profil sayfasından erişilebilir olmalı)
        appState.tabSelection = .profile
        
        // TODO: Siparişler sayfası için ayrı bir navigation flag eklenebilir
        print("📱 Kullanıcı siparişlerini görüntülemek için Profile tab'ına yönlendirildi")
    }
    
    private func goToHome() {
        // Order flow'u temizle
        appState.navigationManager.clearOrderFlow()
        appState.navigationManager.hideAllOrderScreens(appState: appState)
        
        // Home tab'ına geç
        appState.tabSelection = .callUs
    }
}

// MARK: - Payment Card View
struct PaymentCardView: View {
    let card: PaymentCard
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Kart İkonu
                VStack {
                    Image(systemName: cardIcon)
                        .font(.system(size: 24))
                        .foregroundColor(cardColor)
                }
                .frame(width: 40, height: 40)
                .background(cardColor.opacity(0.1))
                .cornerRadius(8)
                
                // Kart Bilgileri
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(card.maskedCardNumber)
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.primary)
                        
                        if card.isDefault {
                            Text("Varsayılan")
                                .font(CustomFont.regular(size: 12))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.logo)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                    
                    Text(card.cardHolderName)
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(card.cardType.rawValue)
                            .font(CustomFont.regular(size: 12))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(card.expiryDate)
                            .font(CustomFont.regular(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Seçim İndikatörü
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.logo)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.logo : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var cardIcon: String {
        switch card.cardType {
        case .visa:
            return "creditcard"
        case .mastercard:
            return "creditcard.fill"
        case .amex:
            return "creditcard"
        case .unknown:
            return "creditcard"
        }
    }
    
    private var cardColor: Color {
        switch card.cardType {
        case .visa:
            return Color.blue
        case .mastercard:
            return Color.orange
        case .amex:
            return Color.green
        case .unknown:
            return Color.gray
        }
    }
}

// MARK: - Add Card View
struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardNumber = ""
    @State private var cardHolderName = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var isDefault = false
    
    // Focus durumları
    @State private var isCardNumberFocused = false
    @State private var isCardHolderFocused = false
    @State private var isExpiryFocused = false
    @State private var isCvvFocused = false
    
    let onCardAdded: (PaymentCard) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Yeni Kart Ekle")
                    .font(CustomFont.bold(size: 24))
                    .foregroundColor(.primary)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kart Numarası")
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.primary)
                        
                        CustomTextField(
                            placeholder: "1234 5678 9012 3456",
                            text: $cardNumber,
                            validation: !cardNumber.isEmpty,
                            isFocused: $isCardNumberFocused
                        )
                        .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kart Sahibi")
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.primary)
                        
                        CustomTextField(
                            placeholder: "AD SOYAD",
                            text: $cardHolderName,
                            validation: !cardHolderName.isEmpty,
                            isFocused: $isCardHolderFocused
                        )
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Son Kullanma")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            CustomTextField(
                                placeholder: "MM/YY",
                                text: $expiryDate,
                                validation: !expiryDate.isEmpty,
                                isFocused: $isExpiryFocused
                            )
                            .keyboardType(.numberPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CVV")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            CustomTextField(
                                placeholder: "123",
                                text: $cvv,
                                validation: !cvv.isEmpty,
                                isFocused: $isCvvFocused
                            )
                            .keyboardType(.numberPad)
                        }
                    }
                    
                    Toggle("Varsayılan kart olarak ayarla", isOn: $isDefault)
                        .font(CustomFont.medium(size: 16))
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: addCard) {
                    Text("Kartı Ekle")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isFormValid ? Color.logo : Color.gray.opacity(0.4))
                        .cornerRadius(16)
                }
                .disabled(!isFormValid)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color("BackgroundColor"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !cardNumber.isEmpty && !cardHolderName.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty
    }
    
    private func addCard() {
        let newCard = PaymentCard(
            id: UUID(),
            cardNumber: cardNumber,
            cardHolderName: cardHolderName.uppercased(),
            expiryDate: expiryDate,
            isDefault: isDefault
        )
        
        onCardAdded(newCard)
        dismiss()
    }
}

