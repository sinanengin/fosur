import Foundation
import SwiftUI

struct Vehicle: Identifiable {
    let id: UUID
    let brand: String
    let model: String
    let plate: String
    let type: VehicleType // String yerine enum oldu!
    let images: [UIImage]
    let userId: UUID
    let lastServices: [String]
}


enum VehicleType: String, CaseIterable {
    case automobile = "Otomobil"
    case suv = "SUV"
    case panelvan = "Panelvan"
    case largeVehicle = "Büyük Araç"

    var displayName: String {
        return self.rawValue
    }
}

