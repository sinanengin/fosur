import Foundation

// MARK: - Payment Card Model
struct PaymentCard: Identifiable, Codable {
    let id: UUID
    let cardNumber: String
    let cardHolderName: String
    let expiryDate: String
    let isDefault: Bool
    
    init(id: UUID = UUID(), cardNumber: String, cardHolderName: String, expiryDate: String, isDefault: Bool = false) {
        self.id = id
        self.cardNumber = cardNumber
        self.cardHolderName = cardHolderName
        self.expiryDate = expiryDate
        self.isDefault = isDefault
    }
    
    // Kart numarasının maskelenmiş versiyonu
    var maskedCardNumber: String {
        let lastFour = String(cardNumber.suffix(4))
        return "**** **** **** \(lastFour)"
    }
    
    // Kart tipi belirleme (Visa, MasterCard, etc.)
    var cardType: CardType {
        let firstDigit = cardNumber.prefix(1)
        switch firstDigit {
        case "4":
            return .visa
        case "5":
            return .mastercard
        case "3":
            return .amex
        default:
            return .unknown
        }
    }
}

enum CardType: String, CaseIterable {
    case visa = "Visa"
    case mastercard = "MasterCard"
    case amex = "American Express"
    case unknown = "Bilinmeyen"
    
    var imageName: String {
        switch self {
        case .visa:
            return "visa_logo"
        case .mastercard:
            return "mastercard_logo"
        case .amex:
            return "amex_logo"
        case .unknown:
            return "credit_card"
        }
    }
}

// MARK: - Mock Payment Cards
let mockPaymentCards = [
    PaymentCard(
        cardNumber: "4111111111111111",
        cardHolderName: "SINAN YILDIZ",
        expiryDate: "12/26",
        isDefault: true
    ),
    PaymentCard(
        cardNumber: "5555555555554444",
        cardHolderName: "SINAN YILDIZ",
        expiryDate: "08/25",
        isDefault: false
    ),
    PaymentCard(
        cardNumber: "4242424242424242",
        cardHolderName: "SINAN YILDIZ",
        expiryDate: "03/27",
        isDefault: false
    )
] 