import SwiftUI

struct Vehicle: Identifiable, Hashable {
    var id: UUID
    var brand: String
    var model: String
    var plate: String
    var type: VehicleType
    var images: [UIImage]
    var userId: UUID
    var lastServices: [String] // Geçmiş hizmetler (opsiyonel olarak detaylandırılabilir)

    static func == (lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum VehicleType: String, CaseIterable, Codable {
    case automobile = "Otomobil"
    case suv = "SUV"
    case panelvan = "Panelvan"
    case largeVehicle = "Büyük Araç"

    var displayName: String {
        rawValue
    }
}

// Sample araç örneği
let sampleVehicle = Vehicle(
    id: UUID(),
    brand: "Renault",
    model: "Clio",
    plate: "34 ABC 123",
    type: .automobile,
    images: [UIImage(named: "temp_car")!, UIImage(named: "temp_car")!],
    userId: UUID(),
    lastServices: []
)
