import SwiftUI
import CoreLocation
import WeatherKit

// MARK: - Models (Address, Service ve ServiceCategory artık Order.swift'te tanımlı)

// MARK: - Services (Artık OrderAPIService kullanılıyor)

struct CallUsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedVehicleIndex = 0
    @State private var selectedAddress: Address?
    @State private var selectedServices: Set<Service> = []
    @State private var showAddressSheet = false
    @State private var showServiceSheet = false
    @State private var showLoginSheet = false
    @State private var addresses: [Address] = []
    @State private var services: [Service] = []
    @State private var isLoading = true
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Günaydın"
        case 12..<18:
            return "İyi Günler"
        default:
            return "İyi Akşamlar"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let user = appState.currentUser {
                Text("\(greeting), \(user.name)")
                    .font(CustomFont.bold(size: 28))
                    .padding(.horizontal)
                    .padding(.top, 16)
            }
            
            VStack(spacing: 24) {
                if !appState.isUserLoggedIn {
                    guestPromptView
                } else {
                    // Araç Seçici
                    vehicleSection
                    
                    // Hizmet ve Adres Kartları
                    VStack(spacing: 16) {
                        // Adres Kartı
                        AddressCard(
                            address: selectedAddress,
                            onTap: { showAddressSheet = true }
                        )
                        
                        // Hizmet Kartı
                        ServiceCard(
                            services: Array(selectedServices),
                            onTap: { showServiceSheet = true }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Devam Et Butonu
                    Button(action: handleContinue) {
                        HStack {
                            Text("Devam Et")
                                .font(CustomFont.bold(size: 18))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isFormValid ? Color.logo : Color.gray.opacity(0.4))
                        .cornerRadius(16)
                        .shadow(color: isFormValid ? Color.logo.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
        .sheet(isPresented: $showAddressSheet) {
            AddressSelectionView(
                selectedAddress: $selectedAddress,
                addresses: addresses
            )
        }
        .sheet(isPresented: $showServiceSheet) {
            ServiceSelectionView(
                selectedServices: $selectedServices,
                services: services
            )
        }
        .sheet(isPresented: $showLoginSheet) {
            AuthSelectionSheetView(
                onLoginSuccess: {
                    appState.setLoggedInUser()
                    showLoginSheet = false
                },
                onGuestContinue: {
                    appState.setGuestUser()
                    showLoginSheet = false
                },
                onPhoneLogin: {
                    // NavigationManager sistemi kullanılıyor
                },
                hideGuestOption: false
            )
            .presentationDetents([.fraction(0.55)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            Task {
                await loadData()
                
                // Giriş yapılmışsa araçları her seferinde yeniden yükle
                if appState.isUserLoggedIn {
                    await appState.loadUserVehicles()
                }
            }
        }
        .onChange(of: selectedAddress) { _, address in
            // Adres seçildiğinde yapılacak işlemler
        }
        .onChange(of: selectedVehicleIndex) { _, index in
            // Araç seçildiğinde yapılacak işlemler
        }
    }
    
    private var vehicleSection: some View {
        VStack(spacing: 16) {
            if let vehicles = appState.currentUser?.vehicles {
                if vehicles.isEmpty {
                    // Araç yok durumu
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            Image(systemName: "car")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("Henüz araç eklememişsiniz")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            Text("Araç eklemek için Araçlarım sekmesini kullanın")
                                .font(CustomFont.regular(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Araç Ekle") {
                            appState.tabSelection = .myVehicles
                        }
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(.logo)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.logo.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal)
                } else {
                    // Araçlar var, karosel göster
                    VehicleCarousel(
                        vehicles: vehicles,
                        selectedIndex: $selectedVehicleIndex,
                        onVehicleChange: handleVehicleChange
                    )
                    .padding(.horizontal)
                }
            } else {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .logo))
                        .scaleEffect(1.2)
                    
                    Text("Araçlar yükleniyor...")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                )
                .padding(.horizontal)
            }
        }
    }
    
    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Hizmetlerimizden yararlanabilmek için giriş yapmalısınız.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Button("Giriş Yap") {
                showLoginSheet = true
            }
            .font(CustomFont.medium(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.logo)
            .cornerRadius(10)
            .padding(.horizontal, 40)
            Spacer()
        }
    }
    
    private var isFormValid: Bool {
        selectedAddress != nil && !selectedServices.isEmpty
    }
    
    private func handleVehicleChange() {
        selectedAddress = nil
        selectedServices.removeAll()
    }
    
    private func handleContinue() {
        guard let selectedAddress = selectedAddress,
              !selectedServices.isEmpty,
              let vehicles = appState.currentUser?.vehicles,
              selectedVehicleIndex < vehicles.count else {
            return
        }
        
        let selectedVehicle = vehicles[selectedVehicleIndex]
        
        // Sipariş akışını başlat
        appState.navigationManager.startOrderFlow(
            vehicle: selectedVehicle,
            address: selectedAddress,
            services: Array(selectedServices),
            appState: appState
        )
    }
    
    private func loadData() async {
        isLoading = true
        do {
            // Yeni OrderAPIService kullanarak veri çek
            async let addressesTask = OrderAPIService.shared.getAddresses()
            async let servicesTask = OrderAPIService.shared.getServices()
            
            let (fetchedAddresses, fetchedServices) = try await (addressesTask, servicesTask)
            
            await MainActor.run {
                self.addresses = fetchedAddresses
                self.services = fetchedServices
                self.isLoading = false
            }
        } catch {
            print("Veri yüklenirken hata oluştu: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// MARK: - Weather Card
struct WeatherCard: View {
    let weather: Weather
    
    var body: some View {
        HStack(spacing: 20) {
            // Hava Durumu İkonu
            Image(systemName: weather.currentWeather.symbolName)
                .font(.system(size: 40))
                .foregroundColor(.logo)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(weather.currentWeather.condition.description)
                    .font(CustomFont.medium(size: 18))
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Text("\(Int(weather.currentWeather.temperature.value))°C")
                        .font(CustomFont.bold(size: 28))
                        .foregroundColor(.primary)
                    
                    Text("Nem: %\(Int(weather.currentWeather.humidity * 100))")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}

// MARK: - Vehicle Carousel
struct VehicleCarousel: View {
    let vehicles: [Vehicle]
    @Binding var selectedIndex: Int
    let onVehicleChange: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $selectedIndex) {
                ForEach(Array(vehicles.enumerated()), id: \.element.id) { index, vehicle in
                    VehicleCard(vehicle: vehicle)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            )
            
            // Sayfa göstergesi
            HStack(spacing: 8) {
                ForEach(0..<vehicles.count, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? Color.logo : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}

// Helper function to convert VehicleImage to UIImage
private func convertToUIImage(_ vehicleImages: [VehicleImage]) -> UIImage? {
    return vehicleImages.first.flatMap { vehicleImage in
        // URL'den UIImage yükleme burada yapılabilir, şimdilik placeholder
        UIImage(named: "temp_car")
    }
}

// MARK: - Vehicle Card
struct VehicleCard: View {
    let vehicle: Vehicle
    
    var body: some View {
        HStack(spacing: 16) {
            // Sol taraf - Araç Görseli
            if let uiImage = convertToUIImage(vehicle.images) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Image("temp_car")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Sağ taraf - Araç Bilgileri
            VStack(alignment: .leading, spacing: 12) {
                // Marka ve Model
                Text("\(vehicle.brand) \(vehicle.model)")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                // Plaka
                Text(vehicle.plate)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.secondary)
                
                // Araç Logosu ve Son Sipariş
                HStack(spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.logo)
                    
                    Text("Son Sipariş: 15 Mart 2024")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Sağ üst köşe - Ok işareti
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
    }
}

// MARK: - Address Card
struct AddressCard: View {
    let address: Address?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.logo)
                    
                    Text("Adres")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                if let address = address {
                    Text(address.title)
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(address.fullAddress)
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("Adres Seçin")
                        .font(CustomFont.regular(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            )
        }
    }
}

// MARK: - Service Card
struct ServiceCard: View {
    let services: [Service]
    let onTap: () -> Void
    
    private var totalPrice: Double {
        services.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.logo)
                    
                    Text("Hizmet")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                if !services.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(services) { service in
                                HStack {
                                    Text(service.title)
                                        .font(CustomFont.medium(size: 16))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.2f ₺", service.price))
                                        .font(CustomFont.bold(size: 16))
                                        .foregroundColor(.logo)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack {
                                Text("Toplam Tutar")
                                    .font(CustomFont.medium(size: 16))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(String(format: "%.2f ₺", totalPrice))
                                    .font(CustomFont.bold(size: 18))
                                    .foregroundColor(.logo)
                            }
                        }
                    }
                    .frame(height: 80)
                } else {
                    Text("Hizmet Seçin")
                        .font(CustomFont.regular(size: 16))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            )
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hatası: \(error.localizedDescription)")
    }
}

// MARK: - Weather Card Placeholder
struct WeatherCardPlaceholder: View {
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: "cloud")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Hava durumu yükleniyor...")
                    .font(CustomFont.medium(size: 18))
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    Text("--°C")
                        .font(CustomFont.bold(size: 28))
                        .foregroundColor(.gray)
                    
                    Text("Nem: --%")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}

#Preview {
    CallUsView()
        .environmentObject(AppState())
}
