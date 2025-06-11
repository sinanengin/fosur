import SwiftUI

struct MyVehiclesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vehicleService = VehicleService.shared
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
                headerView

                if !appState.isUserLoggedIn {
                    guestPromptView
                } else if vehicleService.vehicles.isEmpty && !vehicleService.isLoading {
                    noVehicleView
                } else {
                    vehicleListView
                }
            }
            .background(Color("BackgroundColor"))
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                // Sadece ilk seferinde veya araçlar boşsa çek
                if appState.isUserLoggedIn && vehicleService.vehicles.isEmpty {
                    Task {
                        await loadVehicles()
                    }
                }
            }
            .fullScreenCover(isPresented: $appState.showAddVehicleView) {
                AddVehicleView {
                    appState.showAddVehicleView = false
                }
            }
            .sheet(isPresented: $appState.showAuthSheet) {
                AuthSelectionSheetView(
                    onLoginSuccess: {
                        appState.setLoggedInUser()
                        appState.showAuthSheet = false
                    },
                    onGuestContinue: {
                        appState.setGuestUser()
                        appState.showAuthSheet = false
                    },
                    onPhoneLogin: {
                        // Artık NavigationManager sistemi kullanıyoruz
                        // Bu callback artık kullanılmayacak
                    },
                    hideGuestOption: false
                )
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
            }

    }

    private var headerView: some View {
        HStack {
            Text("Araçlarım")
                .font(CustomFont.bold(size: 28))
            Spacer()
            if appState.isUserLoggedIn {
                Button {
                    print("Butona basıldı!")
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    DispatchQueue.main.async {
                        appState.showAddVehicleView = true
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundColor(.primaryText)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Araç ekleyebilmek için önce giriş yapmalısın.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)

            Button("Giriş Yap") {
                appState.showAuthSheet = true
            }
            .font(CustomFont.medium(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.logo)
            .cornerRadius(10)
            .padding(.horizontal)
            .contentShape(Rectangle())
            Spacer()
        }
    }

    private var noVehicleView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Henüz eklenmiş aracınız yok.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)
            Spacer()
        }
    }

    private var vehicleListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if vehicleService.isLoading {
                    ForEach(0..<3, id: \.self) { _ in
                        VehicleCardLoadingView()
                    }
                } else {
                    ForEach(vehicleService.vehicles) { vehicleData in
                        NavigationLink(value: convertToVehicle(vehicleData)) {
                            VehicleCardView(vehicle: convertToVehicle(vehicleData))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .refreshable {
            await loadVehicles()
        }
        .task {
            // Task zaten onAppear'da kontrol ediliyor, tekrar yapmaya gerek yok
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
            Button("Tekrar Dene") {
                Task { await loadVehicles() }
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Helper Methods
    private func loadVehicles() async {
        do {
            try await vehicleService.getVehicles()
        } catch {
            // URLError cancelled hatasını gösterme
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ Request cancelled - normal durum")
                return
            }
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func convertToVehicle(_ vehicleData: VehicleData) -> Vehicle {
        // VehicleData'yı eski Vehicle modeline çevir
        let images = vehicleData.images // VehicleImage türünde
        
        return Vehicle(
            id: UUID(),
            apiId: vehicleData.id,
            brand: vehicleData.brand.name,
            model: vehicleData.model,
            plate: vehicleData.plate,
            type: .automobile,
            images: images.isEmpty ? [VehicleImage(id: UUID().uuidString, url: "", filename: "temp_car", contentType: "image/jpeg", size: 0, isCover: false, uploadedAt: "")] : images,
            userId: UUID(),
            lastServices: []
        )
    }
}

// MARK: - Loading View
struct VehicleCardLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 70)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 16)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 14)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}
