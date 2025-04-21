import Foundation

struct VehicleBrand: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
    var models: [String]
}


let vehicleBrands: [VehicleBrand] = [
    VehicleBrand(name: "Renault", imageName: "renault_logo", models: ["Clio", "Megane", "Symbol"]),
    VehicleBrand(name: "Toyota", imageName: "toyota_logo", models: ["Corolla", "Yaris", "Auris"]),
    VehicleBrand(name: "BMW", imageName: "bmw_logo", models: ["3 Serisi", "5 Serisi", "X5"]),
    VehicleBrand(name: "Mercedes", imageName: "mercedes_logo", models: ["A Serisi", "C Serisi", "E Serisi"]),
    VehicleBrand(name: "Volkswagen", imageName: "vw_logo", models: ["Golf", "Polo", "Passat"]),
    VehicleBrand(name: "Fiat", imageName: "fiat_logo", models: ["Egea", "Punto", "Doblo"])
]

