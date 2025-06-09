import Foundation

// MARK: - Mock Order Data
var mockOrders: [Order] = []

// MARK: - Mock Addresses
var mockAddresses = [
    Address(id: "1", title: "Ev", fullAddress: "Atatürk Mah. Cumhuriyet Cad. No:123 D:4 Kadıköy/İstanbul", latitude: 40.9909, longitude: 29.0233),
    Address(id: "2", title: "İş", fullAddress: "Levent Mah. Teknoloji Cad. No:45 D:12 Beşiktaş/İstanbul", latitude: 41.0820, longitude: 29.0163),
    Address(id: "3", title: "Anne Evi", fullAddress: "Çamlıca Mah. Bağdat Cad. No:234 D:8 Üsküdar/İstanbul", latitude: 41.0213, longitude: 29.0641)
]

// MARK: - Mock Services
let mockServices = [
    Service(id: "1", title: "İç Temizlik", description: "Detaylı iç temizlik hizmeti", price: 299.99, category: .interiorCleaning),
    Service(id: "2", title: "Dış Temizlik", description: "Detaylı dış temizlik hizmeti", price: 199.99, category: .exteriorCleaning),
    Service(id: "3", title: "Pasta Cila", description: "Profesyonel pasta cila hizmeti", price: 499.99, category: .polish),
    Service(id: "4", title: "Motor Temizliği", description: "Motor bölmesi detaylı temizlik", price: 149.99, category: .exteriorCleaning),
    Service(id: "5", title: "Koltuk Yıkama", description: "Özel koltuk temizlik hizmeti", price: 249.99, category: .interiorCleaning)
]

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

// MARK: - API Service Helpers (Gelecekteki API entegrasyonu için)
class OrderAPIService {
    static let shared = OrderAPIService()
    
    // Adres servisini simüle et
    func getAddresses() async throws -> [Address] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 saniye gecikme
        return mockAddresses
    }
    
    // Adres ekleme
    func addAddress(_ address: Address) async throws {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 saniye gecikme
        mockAddresses.append(address)
    }
    
    // Adres silme
    func deleteAddress(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 saniye gecikme
        mockAddresses.removeAll { $0.id == id }
    }
    
    // Hizmet servisini simüle et
    func getServices() async throws -> [Service] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockServices
    }
    
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
