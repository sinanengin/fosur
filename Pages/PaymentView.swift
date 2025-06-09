import SwiftUI

struct PaymentView: View {
    @EnvironmentObject var appState: AppState
    @State private var savedCards: [PaymentCard] = []
    @State private var selectedCard: PaymentCard?
    @State private var isLoading = true
    @State private var showAddCardSheet = false
    
    private var order: Order? {
        appState.navigationManager.currentOrder
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
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
            .background(Color("BackgroundColor"))
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddCardSheet) {
                AddCardView { newCard in
                    savedCards.append(newCard)
                    selectedCard = newCard
                }
            }
            .onAppear {
                loadSavedCards()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                DispatchQueue.main.async {
                    appState.showPayment = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appState.showOrderSummary = true
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Ödeme")
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
                Text("Ödemeyi Tamamla")
                    .font(CustomFont.bold(size: 18))
                
                if let order = order {
                    Text("(\(String(format: "%.2f ₺", order.grandTotal)))")
                        .font(CustomFont.bold(size: 16))
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.logo)
            .cornerRadius(16)
            .shadow(color: Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
        }
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
        
        // Ödeme işlemini simüle et
        print("Ödeme yapılıyor...")
        print("Kart: \(selectedCard.maskedCardNumber)")
        print("Tutar: \(order.grandTotal)")
        
        // Başarılı ödeme sonrası işlemler
        // Burada normalde API çağrısı yapılacak
        
        // Sipariş akışını temizle
        appState.navigationManager.clearOrderFlow()
        appState.navigationManager.hideAllOrderScreens(appState: appState)
        
        // Başarı mesajı göster (şimdilik konsola yazdır)
        print("Ödeme başarılı! Sipariş oluşturuldu.")
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
                        Text(card.cardType)
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
        case "Visa":
            return "creditcard"
        case "Mastercard":
            return "creditcard.fill"
        default:
            return "creditcard"
        }
    }
    
    private var cardColor: Color {
        switch card.cardType {
        case "Visa":
            return Color.blue
        case "Mastercard":
            return Color.orange
        default:
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

#Preview {
    let appState = AppState()
    appState.setLoggedInUser()
    
    return PaymentView()
        .environmentObject(appState)
} 