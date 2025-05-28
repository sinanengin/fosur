import SwiftUI

struct CallUsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedVehicleIndex = 0
    @State private var showVehicleDetail = false

    var user: User {
        appState.currentUser ?? User(
            id: UUID(),
            name: "Sinan",
            surname: "Yıldız",
            email: "",
            phoneNumber: "",
            profileImage: nil,
            vehicles: [
                Vehicle(
                    id: UUID(),
                    brand: "BMW",
                    model: "320i",
                    plate: "34 ABC 123",
                    type: .automobile,
                    images: [UIImage(named: "temp_car") ?? UIImage()],
                    userId: UUID(),
                    lastServices: []
                ),
                Vehicle(
                    id: UUID(),
                    brand: "Mercedes",
                    model: "C200",
                    plate: "34 XYZ 456",
                    type: .automobile,
                    images: [UIImage(named: "temp_car") ?? UIImage()],
                    userId: UUID(),
                    lastServices: []
                ),
                Vehicle(
                    id: UUID(),
                    brand: "Renault",
                    model: "Clio",
                    plate: "06 DEF 789",
                    type: .automobile,
                    images: [UIImage(named: "temp_car") ?? UIImage()],
                    userId: UUID(),
                    lastServices: []
                )
            ]
        )
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Günaydın, \(user.name)"
        case 12..<18: return "İyi günler, \(user.name)"
        case 18..<22: return "İyi akşamlar, \(user.name)"
        default: return "İyi geceler, \(user.name)"
        }
    }

    // Araç sayısı değişirse index'i sıfırla
    private func safeSelectedIndex(for vehicles: [Vehicle]) -> Int {
        guard !vehicles.isEmpty else { return 0 }
        return min(selectedVehicleIndex, vehicles.count - 1)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selamlama (geri tuşu olmadan)
                HStack(alignment: .center) {
                    Text(greeting)
                        .font(CustomFont.bold(size: 26))
                        .foregroundColor(.primary)
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 8)

                // Araç Galerisi (Slider)
                if !user.vehicles.isEmpty {
                    VStack(spacing: 10) {
                        TabView(selection: $selectedVehicleIndex) {
                            ForEach(user.vehicles.indices, id: \ .self) { idx in
                                let vehicle = user.vehicles[idx]
                                VStack(spacing: 8) {
                                    if let uiImage = vehicle.images.first {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: UIScreen.main.bounds.height * 0.18)
                                            .cornerRadius(14)
                                            .shadow(radius: 4)
                                            .onTapGesture {
                                                selectedVehicleIndex = idx
                                                showVehicleDetail = true
                                            }
                                    } else {
                                        Image("temp_car")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: UIScreen.main.bounds.height * 0.18)
                                            .cornerRadius(14)
                                            .shadow(radius: 4)
                                            .onTapGesture {
                                                selectedVehicleIndex = idx
                                                showVehicleDetail = true
                                            }
                                    }
                                    // Araç Bilgi Kartı
                                    HStack(spacing: 14) {
                                        Image("car_logo_placeholder")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(vehicle.brand)
                                                .font(CustomFont.bold(size: 16))
                                            Text(vehicle.model)
                                                .font(CustomFont.regular(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text(vehicle.plate)
                                            .font(CustomFont.medium(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
                                }
                                .padding(.horizontal, 24)
                                .tag(idx)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: UIScreen.main.bounds.height * 0.28)
                        .animation(.easeInOut, value: selectedVehicleIndex)
                        // Dots göstergesi
                        if user.vehicles.count > 1 {
                            HStack(spacing: 8) {
                                ForEach(user.vehicles.indices, id: \ .self) { idx in
                                    Circle()
                                        .fill(idx == selectedVehicleIndex ? Color.logo : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.top, 2)
                        }
                    }
                    .onChange(of: user.vehicles.count) { oldValue, newValue in
                        selectedVehicleIndex = safeSelectedIndex(for: user.vehicles)
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("Henüz araç eklemediniz.")
                            .font(CustomFont.regular(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 24)
                    .frame(height: UIScreen.main.bounds.height * 0.18)
                }

                Spacer()

                // Bizi Çağır Butonu
                Button(action: {
                    // Çağırma işlemi
                }) {
                    Text("Bizi Çağır")
                        .font(CustomFont.bold(size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.logo)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationDestination(isPresented: $showVehicleDetail) {
                // Güvenli araç erişimi
                if !user.vehicles.isEmpty && safeSelectedIndex(for: user.vehicles) < user.vehicles.count {
                    MyVehicleDetailView(vehicle: user.vehicles[safeSelectedIndex(for: user.vehicles)])
                } else {
                    Text("Araç bulunamadı")
                }
            }
        }
    }
}

#Preview {
    CallUsView()
        .environmentObject(AppState())
}
