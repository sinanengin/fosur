import Foundation

// Legacy Address model - CustomerAddress'den dönüştürme için
struct Address: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let fullAddress: String
    let latitude: Double
    let longitude: Double
    
    init(id: String, title: String, fullAddress: String, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.fullAddress = fullAddress
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Equatable conformance
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.id == rhs.id
    }
}

// CustomerAddress extension - Address'e dönüştürme için
extension CustomerAddress {
    func toLegacyAddress() -> Address {
        return Address(
            id: self.id,
            title: self.name,
            fullAddress: self.formattedAddress,
            latitude: self.latitude,
            longitude: self.longitude
        )
    }
} 