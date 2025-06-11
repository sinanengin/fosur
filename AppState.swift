import SwiftUI

class AppState: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    @Published var navigationManager = NavigationManager()
    @Published var tabSelection: TabItem = .callUs
    @Published var showAddVehicleView = false // EKLEDİK
    @Published var showAuthSheet = false // Giriş yaparken açılan sheet
    @Published var isFromOnboarding = false // Onboarding'den gelip gelmediğini takip eder
    @Published var isLoadingAuth = true // Auto-login sırasında splash screen için
    
    // Sipariş akışı state'leri
    @Published var showDateTimeSelection = false
    @Published var showOrderSummary = false
    @Published var showPayment = false
    
    private let authService = AuthService.shared
    private let vehicleService = VehicleService.shared

    init() {
        // Uygulama başladığında auto-login kontrolü yap
        checkAutoLogin()
    }
    
    // MARK: - Auto Login
    func checkAutoLogin() {
        print("🚀 AppState: Auto-login kontrolü başlıyor")
        isLoadingAuth = true
        
        Task {
            do {
                let success = try await authService.autoLoginWithStoredAuth()
                
                await MainActor.run {
                    if success {
                        // Auto-login başarılı, customer bilgilerini al
                        self.setupUserFromAuth()
                        print("✅ Auto-login başarılı, kullanıcı giriş yapıldı")
                    } else {
                        print("❌ Auto-login başarısız, giriş ekranı gösterilecek")
                    }
                    self.isLoadingAuth = false
                }
            } catch {
                print("❌ Auto-login hatası: \(error)")
                await MainActor.run {
                    self.isLoadingAuth = false
                }
            }
        }
    }
    
    // AuthService'teki bilgilerden User oluştur
    func setupUserFromAuth() {
        guard let userDetails = authService.currentUser else {
            print("❌ AuthService'te user details bulunamadı")
            return
        }
        
        // Customer bilgilerini almak için API çağrısı yap
        Task {
            do {
                let customers = try await CustomerService.shared.searchCustomers(userId: userDetails.id)
                
                await MainActor.run {
                    if let customer = customers.first {
                        self.currentUser = User(
                            id: UUID(),
                            name: customer.name.givenName,
                            surname: customer.name.lastName,
                            email: customer.email ?? "",
                            phoneNumber: userDetails.phoneNumber,
                            profileImage: nil,
                            vehicles: [] // Araçlar ayrıca yüklenecek
                        )
                        self.isUserLoggedIn = true
                        
                        print("✅ User bilgileri AppState'e yüklendi")
                        print("👤 Ad: \(customer.name.givenName)")
                        print("👤 Soyad: \(customer.name.lastName)")
                        
                        // Araçları da yükle
                        Task {
                            await self.loadUserVehicles()
                        }
                    }
                }
            } catch {
                print("❌ Customer bilgileri alınırken hata: \(error)")
            }
        }
    }
    
    // MARK: - Vehicle Management
    func loadUserVehicles(forceRefresh: Bool = false) async {
        guard isUserLoggedIn else {
            print("❌ Kullanıcı giriş yapmamış, araçlar yüklenemez")
            return
        }
        
        // Cache varsa ve force refresh yoksa, mevcut araçları kullan
        if !forceRefresh, let vehicles = currentUser?.vehicles, !vehicles.isEmpty {
            print("✅ AppState: Cache'den \(vehicles.count) araç kullanılıyor")
            return
        }
        
        do {
            print("🚗 AppState: Kullanıcı araçları yükleniyor... (forceRefresh: \(forceRefresh))")
            let vehicleDataArray = try await vehicleService.getVehicles(forceRefresh: forceRefresh)
            
            // VehicleData'yı Vehicle model'ine çevir
            let vehicles = vehicleDataArray.map { vehicleData in
                convertVehicleDataToVehicle(vehicleData)
            }
            
            await MainActor.run {
                self.currentUser?.vehicles = vehicles
                print("✅ AppState: \(vehicles.count) araç yüklendi")
                
                // Debug: Araç detaylarını logla
                for vehicle in vehicles {
                    print("🚗 Araç: \(vehicle.brand) \(vehicle.model) - \(vehicle.plate)")
                    print("🆔 API ID: \(vehicle.apiId ?? "N/A")")
                    print("📸 Fotoğraf sayısı: \(vehicle.images.count)")
                }
            }
        } catch {
            print("❌ AppState: Araçlar yüklenirken hata: \(error)")
        }
    }
    
    // VehicleData'yı Vehicle model'ine çevir
    private func convertVehicleDataToVehicle(_ vehicleData: VehicleData) -> Vehicle {
        let images = vehicleData.images.isEmpty ? 
            [VehicleImage(id: UUID().uuidString, url: "", filename: "temp_car", contentType: "image/jpeg", size: 0, isCover: false, uploadedAt: "")] : 
            vehicleData.images
        
        return Vehicle(
            id: UUID(),
            apiId: vehicleData.id,
            brand: vehicleData.brand.name,
            model: vehicleData.model,
            plate: vehicleData.plate,
            type: .automobile,
            images: images,
            userId: UUID(),
            lastServices: [],
            name: vehicleData.name
        )
    }

    func setGuestUser() {
        self.isUserLoggedIn = false
        self.currentUser = User(
            id: UUID(),
            name: "Misafir",
            surname: "Kullanıcı",
            email: "misafir@fosur.com",
            phoneNumber: "Yok",
            profileImage: nil,
            vehicles: []
        )
    }

    func setLoggedInUser() {
        self.isUserLoggedIn = true
        self.currentUser = User(
            id: UUID(),
            name: "Deneme",
            surname: "Kullanıcı",
            email: "deneme@fosur.com",
            phoneNumber: "5551234567",
            profileImage: nil,
            vehicles: [
                Vehicle(
                    id: UUID(),
                    brand: "BMW",
                    model: "320i",
                    plate: "34 ABC 123",
                    type: .automobile,
                    images: [VehicleImage(id: UUID().uuidString, url: "", filename: "temp_car", contentType: "image/jpeg", size: 0, isCover: false, uploadedAt: "")],
                    userId: UUID(),
                    lastServices: []
                ),
                Vehicle(
                    id: UUID(),
                    brand: "Mercedes",
                    model: "C200",
                    plate: "34 XYZ 456",
                    type: .automobile,
                    images: [VehicleImage(id: UUID().uuidString, url: "", filename: "temp_car", contentType: "image/jpeg", size: 0, isCover: false, uploadedAt: "")],
                    userId: UUID(),
                    lastServices: []
                ),
                Vehicle(
                    id: UUID(),
                    brand: "Renault",
                    model: "Clio",
                    plate: "06 DEF 789",
                    type: .automobile,
                    images: [VehicleImage(id: UUID().uuidString, url: "", filename: "temp_car", contentType: "image/jpeg", size: 0, isCover: false, uploadedAt: "")],
                    userId: UUID(),
                    lastServices: []
                )
            ]
        )
    }
}
