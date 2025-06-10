import SwiftUI

struct Vehicle: Identifiable, Hashable, Codable {
    var id: UUID
    var apiId: String? // API'dan gelen gerçek ID
    var brand: String
    var model: String
    var plate: String
    var type: VehicleType
    var images: [VehicleImage]
    var userId: UUID
    var lastServices: [String]
    var name: String? // Araç ismi

    enum CodingKeys: String, CodingKey {
        case id, apiId, brand, model, plate, type, userId, lastServices, name
    }

    init(id: UUID, apiId: String? = nil, brand: String, model: String, plate: String, type: VehicleType, images: [VehicleImage], userId: UUID, lastServices: [String], name: String? = nil) {
        self.id = id
        self.apiId = apiId
        self.brand = brand
        self.model = model
        self.plate = plate
        self.type = type
        self.images = images
        self.userId = userId
        self.lastServices = lastServices
        self.name = name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        apiId = try container.decodeIfPresent(String.self, forKey: .apiId)
        brand = try container.decode(String.self, forKey: .brand)
        model = try container.decode(String.self, forKey: .model)
        plate = try container.decode(String.self, forKey: .plate)
        type = try container.decode(VehicleType.self, forKey: .type)
        userId = try container.decode(UUID.self, forKey: .userId)
        lastServices = try container.decode([String].self, forKey: .lastServices)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        images = [] // images are excluded from decoding
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(apiId, forKey: .apiId)
        try container.encode(brand, forKey: .brand)
        try container.encode(model, forKey: .model)
        try container.encode(plate, forKey: .plate)
        try container.encode(type, forKey: .type)
        try container.encode(userId, forKey: .userId)
        try container.encode(lastServices, forKey: .lastServices)
        try container.encodeIfPresent(name, forKey: .name)
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

// MARK: - Vehicle Brand (tanımı MockVehicleData.swift'te var)

// Sample araç örneği
let sampleVehicle = Vehicle(
    id: UUID(),
    brand: "Renault",
    model: "Clio",
    plate: "34 ABC 123",
    type: .automobile,
    images: [], // Görseller AppState'te tanımlanıyor
    userId: UUID(),
    lastServices: [],
    name: "Renault Clio"
)
