import Foundation

struct MockVehicleBrand: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
    var models: [String]
}

let vehicleBrands: [MockVehicleBrand] = [
    // Alman Markalar
    MockVehicleBrand(name: "BMW", imageName: "bmw_logo", models: [
        "1 Serisi", "2 Serisi", "3 Serisi", "4 Serisi", "5 Serisi", "6 Serisi", "7 Serisi", "8 Serisi",
        "X1", "X2", "X3", "X4", "X5", "X6", "X7", "Z4", "i3", "i4", "iX", "iX3"
    ]),
    
    MockVehicleBrand(name: "Mercedes-Benz", imageName: "mercedes_logo", models: [
        "A Serisi", "B Serisi", "C Serisi", "CLA", "CLS", "E Serisi", "G Serisi", "GLA", "GLB", "GLC", 
        "GLE", "GLS", "S Serisi", "SL", "AMG GT", "EQA", "EQB", "EQC", "EQE", "EQS", "V Serisi"
    ]),
    
    MockVehicleBrand(name: "Audi", imageName: "audi_logo", models: [
        "A1", "A3", "A4", "A5", "A6", "A7", "A8", "Q2", "Q3", "Q4", "Q5", "Q7", "Q8", 
        "TT", "R8", "e-tron GT", "Q4 e-tron", "e-tron"
    ]),
    
    MockVehicleBrand(name: "Volkswagen", imageName: "vw_logo", models: [
        "Polo", "Golf", "Jetta", "Passat", "Arteon", "T-Cross", "T-Roc", "Tiguan", "Touareg", 
        "Caddy", "Transporter", "Crafter", "ID.3", "ID.4", "ID.5", "ID.Buzz"
    ]),
    
    MockVehicleBrand(name: "Porsche", imageName: "porsche_logo", models: [
        "911", "718 Boxster", "718 Cayman", "Panamera", "Cayenne", "Macan", "Taycan"
    ]),
    
    // Japon Markalar
    MockVehicleBrand(name: "Toyota", imageName: "toyota_logo", models: [
        "Yaris", "Corolla", "Camry", "Avalon", "C-HR", "RAV4", "Highlander", "Land Cruiser", 
        "Prius", "Prius Prime", "Mirai", "Supra", "86", "Sienna", "Tacoma", "Tundra"
    ]),
    
    MockVehicleBrand(name: "Honda", imageName: "honda_logo", models: [
        "Civic", "Accord", "City", "Jazz", "HR-V", "CR-V", "Pilot", "Passport", "Ridgeline", 
        "Insight", "Clarity", "NSX"
    ]),
    
    MockVehicleBrand(name: "Nissan", imageName: "nissan_logo", models: [
        "Micra", "Sentra", "Altima", "Maxima", "Juke", "Qashqai", "X-Trail", "Murano", 
        "Pathfinder", "Armada", "Leaf", "Ariya", "370Z", "GT-R"
    ]),
    
    MockVehicleBrand(name: "Mazda", imageName: "mazda_logo", models: [
        "Mazda2", "Mazda3", "Mazda6", "CX-3", "CX-30", "CX-5", "CX-9", "MX-5", "MX-30"
    ]),
    
    MockVehicleBrand(name: "Subaru", imageName: "subaru_logo", models: [
        "Impreza", "Legacy", "Outback", "Forester", "Ascent", "WRX", "BRZ", "Crosstrek"
    ]),
    
    MockVehicleBrand(name: "Lexus", imageName: "lexus_logo", models: [
        "IS", "ES", "GS", "LS", "UX", "NX", "RX", "GX", "LX", "LC", "RC"
    ]),
    
    // Fransız Markalar
    MockVehicleBrand(name: "Renault", imageName: "renault_logo", models: [
        "Clio", "Captur", "Megane", "Talisman", "Koleos", "Kadjar", "Scenic", "Espace", 
        "Master", "Kangoo", "Zoe", "Twingo", "Dacia Duster", "Dacia Logan", "Dacia Sandero"
    ]),
    
    MockVehicleBrand(name: "Peugeot", imageName: "peugeot_logo", models: [
        "208", "2008", "308", "3008", "408", "508", "5008", "Partner", "Expert", "Boxer", 
        "e-208", "e-2008", "e-308"
    ]),
    
    MockVehicleBrand(name: "Citroën", imageName: "citroen_logo", models: [
        "C1", "C3", "C3 Aircross", "C4", "C5 Aircross", "Berlingo", "SpaceTourer", "Jumpy", 
        "Jumper", "ë-C4", "Ami"
    ]),
    
    // İtalyan Markalar
    MockVehicleBrand(name: "Fiat", imageName: "fiat_logo", models: [
        "500", "Panda", "Tipo", "Egea", "500X", "500L", "Doblo", "Ducato", "500e"
    ]),
    
    MockVehicleBrand(name: "Alfa Romeo", imageName: "alfaromeo_logo", models: [
        "Giulia", "Stelvio", "Giulietta", "4C", "Tonale"
    ]),
    
    MockVehicleBrand(name: "Ferrari", imageName: "ferrari_logo", models: [
        "488", "F8", "SF90", "LaFerrari", "Portofino", "Roma", "812", "296"
    ]),
    
    MockVehicleBrand(name: "Lamborghini", imageName: "lamborghini_logo", models: [
        "Huracán", "Aventador", "Urus", "Revuelto"
    ]),
    
    // Amerikan Markalar
    MockVehicleBrand(name: "Ford", imageName: "ford_logo", models: [
        "Fiesta", "Focus", "Mondeo", "Mustang", "EcoSport", "Kuga", "Edge", "Explorer", 
        "F-150", "Ranger", "Transit", "Bronco", "Mach-E"
    ]),
    
    MockVehicleBrand(name: "Chevrolet", imageName: "chevrolet_logo", models: [
        "Spark", "Sonic", "Cruze", "Malibu", "Camaro", "Corvette", "Trax", "Equinox", 
        "Traverse", "Tahoe", "Suburban", "Silverado", "Bolt"
    ]),
    
    MockVehicleBrand(name: "Tesla", imageName: "tesla_logo", models: [
        "Model 3", "Model S", "Model X", "Model Y", "Cybertruck", "Roadster"
    ]),
    
    // Kore Markalar
    MockVehicleBrand(name: "Hyundai", imageName: "hyundai_logo", models: [
        "i10", "i20", "i30", "Elantra", "Sonata", "Azera", "Kona", "Tucson", "Santa Fe", 
        "Palisade", "Ioniq", "Ioniq 5", "Ioniq 6"
    ]),
    
    MockVehicleBrand(name: "Kia", imageName: "kia_logo", models: [
        "Picanto", "Rio", "Ceed", "Cerato", "Optima", "Stonic", "Sportage", "Sorento", 
        "Mohave", "Niro", "EV6", "Soul"
    ]),
    
    MockVehicleBrand(name: "Genesis", imageName: "genesis_logo", models: [
        "G70", "G80", "G90", "GV60", "GV70", "GV80"
    ]),
    
    // İsveç Markalar
    MockVehicleBrand(name: "Volvo", imageName: "volvo_logo", models: [
        "S60", "S90", "V60", "V90", "XC40", "XC60", "XC90", "C40", "EX30", "EX90"
    ]),
    
    // İngiliz Markalar
    MockVehicleBrand(name: "MINI", imageName: "mini_logo", models: [
        "Cooper", "Clubman", "Countryman", "Convertible", "Electric"
    ]),
    
    MockVehicleBrand(name: "Land Rover", imageName: "landrover_logo", models: [
        "Range Rover", "Range Rover Sport", "Range Rover Velar", "Range Rover Evoque", 
        "Discovery", "Discovery Sport", "Defender"
    ]),
    
    MockVehicleBrand(name: "Jaguar", imageName: "jaguar_logo", models: [
        "XE", "XF", "XJ", "F-Pace", "E-Pace", "I-Pace", "F-Type"
    ]),
    
    // Çek Markalar
    MockVehicleBrand(name: "Škoda", imageName: "skoda_logo", models: [
        "Fabia", "Scala", "Octavia", "Superb", "Kamiq", "Karoq", "Kodiaq", "Enyaq"
    ]),
    
    // Türk Markalar
    MockVehicleBrand(name: "TOGG", imageName: "togg_logo", models: [
        "T10F", "T10S", "T10X"
    ])
]

