import SwiftUI

struct OrderSummaryView: View {
    @EnvironmentObject var appState: AppState
    
    private var order: Order? {
        appState.navigationManager.currentOrder
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Başlık
                        VStack(spacing: 8) {
                            Text("Sipariş Özeti")
                                .font(CustomFont.bold(size: 28))
                                .foregroundColor(.primary)
                            
                            Text("Sipariş detaylarınızı kontrol edin")
                                .font(CustomFont.regular(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        if let order = order {
                            VStack(spacing: 20) {
                                // Araç Bilgileri
                                vehicleCard(order.vehicle)
                                
                                // Adres Bilgileri
                                addressCard(order.address)
                                
                                // Hizmet Saati
                                serviceTimeCard(order)
                                
                                // Seçilen Hizmetler
                                servicesCard(order.selectedServices)
                                
                                // Fiyat Detayları
                                priceCard(order)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Ödeme Adımına Devam Butonu
                        continueButton
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                DispatchQueue.main.async {
                    appState.showOrderSummary = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    appState.showDateTimeSelection = true
                }
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Sipariş Özeti")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Boş alan - buton boyutu için
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Color("BackgroundColor"))
    }
    
    private func vehicleCard(_ vehicle: Vehicle?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "car.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                Text("Araç Bilgileri")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            if let vehicle = vehicle {
                HStack(spacing: 16) {
                    // Araç Görseli
                    if let uiImage = vehicle.images.first {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image("temp_car")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(vehicle.brand) \(vehicle.model)")
                            .font(CustomFont.bold(size: 16))
                            .foregroundColor(.primary)
                        
                        Text(vehicle.plate)
                            .font(CustomFont.medium(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text(vehicle.type.displayName)
                            .font(CustomFont.regular(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func addressCard(_ address: Address) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                Text("Hizmet Adresi")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(address.title)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Text(address.fullAddress)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func serviceTimeCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                Text("Hizmet Saati")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tarih")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(DateFormatter.displayDate.string(from: order.serviceDate))
                        .font(CustomFont.bold(size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Saat")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(order.serviceTime)
                        .font(CustomFont.bold(size: 16))
                        .foregroundColor(.logo)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func servicesCard(_ services: [Service]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                Text("Seçilen Hizmetler")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(services) { service in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(service.title)
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            Text(service.description)
                                .font(CustomFont.regular(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.2f ₺", service.price))
                            .font(CustomFont.bold(size: 16))
                            .foregroundColor(.logo)
                    }
                    .padding(.vertical, 4)
                    
                    if service.id != services.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private func priceCard(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                Text("Fiyat Detayları")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Hizmet Tutarı")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f ₺", order.totalAmount))
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Yol Ücreti")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f ₺", order.travelFee))
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Text("Toplam Tutar")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f ₺", order.grandTotal))
                        .font(CustomFont.bold(size: 20))
                        .foregroundColor(.logo)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    private var continueButton: some View {
        Button(action: {
            // Ödeme sayfasına geç
            appState.navigationManager.showPaymentScreen(appState: appState)
        }) {
            HStack {
                Text("Ödeme Adımına Devam Et")
                    .font(CustomFont.bold(size: 18))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.logo)
            .cornerRadius(16)
            .shadow(color: Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    let appState = AppState()
    appState.setLoggedInUser()
    
    // Mock order oluştur
    let mockVehicle = Vehicle(
        id: UUID(),
        brand: "BMW",
        model: "320i",
        plate: "34 ABC 123",
        type: .automobile,
        images: [],
        userId: UUID(),
        lastServices: []
    )
    
    let mockAddress = Address(
        id: "1",
        title: "Ev",
        fullAddress: "Atatürk Mah. Cumhuriyet Cad. No:123 D:4 Kadıköy/İstanbul",
        latitude: 40.9909,
        longitude: 29.0233
    )
    
    let mockServices = [
        Service(id: "1", title: "İç Temizlik", description: "Detaylı iç temizlik hizmeti", price: 299.99, category: .interiorCleaning),
        Service(id: "2", title: "Dış Temizlik", description: "Detaylı dış temizlik hizmeti", price: 199.99, category: .exteriorCleaning)
    ]
    
    appState.navigationManager.currentOrder = Order(
        vehicleId: mockVehicle.id,
        vehicle: mockVehicle,
        address: mockAddress,
        selectedServices: mockServices,
        serviceDate: Date(),
        serviceTime: "14:30",
        totalAmount: 499.98
    )
    
    return OrderSummaryView()
        .environmentObject(appState)
} 