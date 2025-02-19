import Foundation

struct Order: Identifiable {
    let id: UUID
    let vehicleId: UUID
    let date: Date
    let services: [String]
    let beforeImages: [String]
    let afterImages: [String]
    let price: Double
}
