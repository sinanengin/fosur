import Foundation
import UIKit

// MARK: - Order Model
struct Order: Identifiable, Codable {
    let id: UUID
    let vehicleId: UUID
    let vehicle: Vehicle?
    let address: Address
    let selectedServices: [Service]
    let serviceDate: Date
    let serviceTime: String
    let totalAmount: Double
    let travelFee: Double
    let status: OrderStatus
    let createdAt: Date
    
    var grandTotal: Double {
        totalAmount + travelFee
    }
    
    init(id: UUID = UUID(), vehicleId: UUID, vehicle: Vehicle?, address: Address, selectedServices: [Service], serviceDate: Date, serviceTime: String, totalAmount: Double, travelFee: Double = 50.0, status: OrderStatus = .pending, createdAt: Date = Date()) {
        self.id = id
        self.vehicleId = vehicleId
        self.vehicle = vehicle
        self.address = address
        self.selectedServices = selectedServices
        self.serviceDate = serviceDate
        self.serviceTime = serviceTime
        self.totalAmount = totalAmount
        self.travelFee = travelFee
        self.status = status
        self.createdAt = createdAt
    }
}

// MARK: - Order Status
enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Bekliyor"
    case confirmed = "Onaylandı"
    case inProgress = "Devam Ediyor"
    case completed = "Tamamlandı"
    case cancelled = "İptal Edildi"
    
    var displayName: String {
        rawValue
    }
}

// MARK: - Time Slot
struct TimeSlot: Identifiable, Hashable {
    let id: String
    let time: String
    let isAvailable: Bool
    
    init(time: String, isAvailable: Bool = true) {
        self.id = time
        self.time = time
        self.isAvailable = isAvailable
    }
}

// MARK: - Payment Card
struct PaymentCard: Identifiable, Codable {
    let id: UUID
    let cardNumber: String
    let cardHolderName: String
    let expiryDate: String
    let isDefault: Bool
    
    var maskedCardNumber: String {
        let last4 = String(cardNumber.suffix(4))
        return "**** **** **** \(last4)"
    }
    
    var cardType: String {
        if cardNumber.hasPrefix("4") {
            return "Visa"
        } else if cardNumber.hasPrefix("5") {
            return "Mastercard"
        } else {
            return "Bilinmeyen"
        }
    }
}

// MARK: - Service Definition (already exists in CallUsView but moving here)
struct Address: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let fullAddress: String
    let latitude: Double
    let longitude: Double
    
    static func == (lhs: Address, rhs: Address) -> Bool {
        lhs.id == rhs.id
    }
}

struct Service: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let images: [String]
    
    // ServiceData'dan Service'e dönüştürme için init
    init(from serviceData: ServiceData) {
        self.id = serviceData.id
        self.title = serviceData.name
        self.description = serviceData.details
        self.price = serviceData.price
        self.images = serviceData.images
    }
    
    // Mevcut Service'ler için standart init
    init(id: String, title: String, description: String, price: Double, images: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.images = images
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Service, rhs: Service) -> Bool {
        lhs.id == rhs.id
    }
}
