import Foundation

// MARK: - Mock Order Data
var mockOrders: [Order] = []

// MARK: - Mock Payment Cards
let mockPaymentCards = [
    PaymentCard(
        id: UUID(),
        cardNumber: "4111111111111111",
        cardHolderName: "SINAN YILDIZ",
        expiryDate: "12/26",
        isDefault: true
    ),
    PaymentCard(
        id: UUID(),
        cardNumber: "5555555555554444",
        cardHolderName: "SINAN YILDIZ",
        expiryDate: "08/25",
        isDefault: false
    ),
    PaymentCard(
        id: UUID(),
        cardNumber: "4242424242424242",
        cardHolderName: "SINAN YILDIZ",
        expiryDate: "03/27",
        isDefault: false
    )
]

// MARK: - Mock Time Slots (API entegrasyonu için hazır)
func generateMockTimeSlots(for date: Date) -> [TimeSlot] {
    var slots: [TimeSlot] = []
    
    // 24 saat, yarım saat aralıklarla
    for hour in 0..<24 {
        for minute in [0, 30] {
            let timeString = String(format: "%02d:%02d", hour, minute)
            // Bazı saatleri rastgele dolu yap (gerçek API'de rezervasyon verisine göre gelecek)
            let isAvailable = !["08:30", "12:00", "15:30", "18:00", "20:30"].contains(timeString)
            slots.append(TimeSlot(time: timeString, isAvailable: isAvailable))
        }
    }
    
    return slots
}

// MARK: - API Service Helpers (Sipariş ve ödeme API'leri için)
class OrderAPIService {
    static let shared = OrderAPIService()
    
    // Müsait saatleri getir
    func getAvailableTimeSlots(for date: Date) async throws -> [TimeSlot] {
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 saniye gecikme
        return generateMockTimeSlots(for: date)
    }
    
    // Kayıtlı kartları getir
    func getSavedCards() async throws -> [PaymentCard] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 saniye gecikme
        return mockPaymentCards
    }
    
    // Sipariş oluştur
    func createOrder(_ order: Order) async throws -> Order {
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 saniye gecikme (ödeme işlemi simülasyonu)
        
        // Başarılı sipariş oluşturma simülasyonu
        var createdOrder = order
        // Burada normalde API'den dönen güncellenmiş sipariş bilgisi gelecek
        
        mockOrders.append(createdOrder)
        return createdOrder
    }
    
    // Ödeme işlemi
    func processPayment(order: Order, card: PaymentCard) async throws -> Bool {
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 saniye gecikme
        
        // %95 başarı oranı simülasyonu
        let isSuccessful = Bool.random() ? true : true // Şimdilik her zaman başarılı
        
        if !isSuccessful {
            throw PaymentError.transactionFailed
        }
        
        return true
    }
}

// MARK: - Error Types (API entegrasyonu için)
enum PaymentError: Error, LocalizedError {
    case transactionFailed
    case cardDeclined
    case insufficientFunds
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .transactionFailed:
            return "İşlem başarısız oldu. Lütfen tekrar deneyin."
        case .cardDeclined:
            return "Kartınız reddedildi. Lütfen başka bir kart deneyin."
        case .insufficientFunds:
            return "Yetersiz bakiye. Lütfen başka bir kart deneyin."
        case .networkError:
            return "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
        }
    }
}
