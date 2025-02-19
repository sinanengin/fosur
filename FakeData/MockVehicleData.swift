import Foundation

struct VehicleBrand {
    let name: String
    let models: [String]
}

let vehicleBrands: [VehicleBrand] = [
    VehicleBrand(name: "Renault", models: ["Clio", "Megane", "Symbol"]),
    VehicleBrand(name: "Toyota", models: ["Corolla", "Yaris", "Camry"]),
    VehicleBrand(name: "Volkswagen", models: ["Golf", "Passat", "Tiguan"]),
    VehicleBrand(name: "Ford", models: ["Focus", "Fiesta", "Kuga"])
]
