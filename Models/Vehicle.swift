import SwiftUI

struct Vehicle: Identifiable, Hashable, Codable {
    var id: UUID
    var brand: String
    var model: String
    var plate: String
    var type: VehicleType
    var images: [UIImage]
    var userId: UUID
    var lastServices: [String]

    enum CodingKeys: String, CodingKey {
        case id, brand, model, plate, type, userId, lastServices
    }

    init(id: UUID, brand: String, model: String, plate: String, type: VehicleType, images: [UIImage], userId: UUID, lastServices: [String]) {
        self.id = id
        self.brand = brand
        self.model = model
        self.plate = plate
        self.type = type
        self.images = images
        self.userId = userId
        self.lastServices = lastServices
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        brand = try container.decode(String.self, forKey: .brand)
        model = try container.decode(String.self, forKey: .model)
        plate = try container.decode(String.self, forKey: .plate)
        type = try container.decode(VehicleType.self, forKey: .type)
        userId = try container.decode(UUID.self, forKey: .userId)
        lastServices = try container.decode([String].self, forKey: .lastServices)
        images = [] // images are excluded from decoding
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(brand, forKey: .brand)
        try container.encode(model, forKey: .model)
        try container.encode(plate, forKey: .plate)
        try container.encode(type, forKey: .type)
        try container.encode(userId, forKey: .userId)
        try container.encode(lastServices, forKey: .lastServices)
        // images are excluded from encoding
    }

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
