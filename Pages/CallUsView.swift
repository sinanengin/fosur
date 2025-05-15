import SwiftUI

struct CallUsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedVehicleIndex = 0
    @State private var isConfirmed = false
    @State private var navigateToMyVehicles = false
    @State private var navigateToAddresses = false
    @State private var navigateToServices = false

    var user: User {
        appState.currentUser ?? User(
            id: UUID(),
            name: "Sinan",
            surname: "Yıldız",
            email: "",
            phoneNumber: "",
            profileImage: nil
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hoşgeldin
                    Text("Hoşgeldin, \(user.name)")
                        .font(CustomFont.bold(size: 24))
                        .padding(.top)
                        .padding(.horizontal)

                    // Araç Kartı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Araç Seçimi")
                            .font(CustomFont.medium(size: 16))
                            .padding(.horizontal)

                        vehicleCard
                    }

                    // Adres Kartı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Adres Seçimi")
                            .font(CustomFont.medium(size: 16))
                            .padding(.horizontal)

                        addressCard
                    }

                    // Hizmet Kartı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hizmet Seçimi")
                            .font(CustomFont.medium(size: 16))
                            .padding(.horizontal)

                        serviceCard
                    }

                    // Onay Kutusu
                    Toggle(isOn: $isConfirmed) {
                        Text("Araç ve adres bilgilerimin doğru olduğunu onaylıyorum.")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle(tint: .logo))
                    
                    
                    // Buton
                    Button("Bizi Çağır") {
                        print("Servis çağırma işlemi başlatıldı.")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isConfirmed && hasValidSelection ? Color.logo : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(!(isConfirmed && hasValidSelection))

                    Spacer(minLength: 40)
                }
            }
            .navigationDestination(isPresented: $navigateToMyVehicles) {
                MyVehiclesView()
            }
            .navigationDestination(isPresented: $navigateToAddresses) {
                Text("Adreslerim Sayfası (Yapılacak)")
            }
            .navigationDestination(isPresented: $navigateToServices) {
                Text("Hizmetler Sayfası (Yapılacak)")
            }
            .background(Color("BackgroundColor"))
        }
    }

    private var vehicleCard: some View {
        Group {
            if user.vehicles.isEmpty {
                emptyCard(text: "Henüz araç eklemedin. Hemen ekle!") {
                    navigateToMyVehicles = true
                }
            } else {
                HStack {
                    if user.vehicles.count > 1 {
                        Button(action: {
                            if selectedVehicleIndex > 0 {
                                selectedVehicleIndex -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }
                    }

                    let vehicle = user.vehicles[selectedVehicleIndex]
                    HStack(spacing: 16) {
                        Image("car_logo_placeholder")
                            .resizable()
                            .frame(width: 60, height: 60)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(vehicle.brand)
                                .font(CustomFont.bold(size: 16))
                            Text(vehicle.model)
                                .font(CustomFont.regular(size: 14))
                            Text(vehicle.plate)
                                .font(CustomFont.medium(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .onTapGesture {
                        navigateToMyVehicles = true
                    }

                    if user.vehicles.count > 1 {
                        Button(action: {
                            if selectedVehicleIndex < user.vehicles.count - 1 {
                                selectedVehicleIndex += 1
                            }
                        }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var addressCard: some View {
        emptyCard(text: "Henüz adres eklemedin. Hemen ekle!") {
            navigateToAddresses = true
        }
    }

    private var serviceCard: some View {
        emptyCard(text: "Henüz hizmet seçmediniz.") {
            navigateToServices = true
        }
    }

    private func emptyCard(text: String, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
        .padding(.horizontal)
        .onTapGesture(perform: onTap)
    }

    private var hasValidSelection: Bool {
        !user.vehicles.isEmpty // + adres ve hizmet kontrolü eklenecek
    }
}

#Preview {
    CallUsView()
        .environmentObject(AppState())
}
