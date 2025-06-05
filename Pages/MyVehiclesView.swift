import SwiftUI

struct MyVehiclesView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack(path: $appState.navigationManager.navigationPath) {
            VStack(spacing: 0) {
                headerView

                if !appState.isUserLoggedIn {
                    guestPromptView
                } else if appState.currentUser?.vehicles.isEmpty ?? true {
                    noVehicleView
                } else {
                    vehicleListView
                }
            }
            .background(Color("BackgroundColor"))
            .ignoresSafeArea(edges: .bottom)
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
            .navigationDestination(for: Vehicle.self) { vehicle in
                MyVehicleDetailView(vehicle: vehicle)
            }
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
                ForEach(appState.currentUser?.vehicles ?? []) { vehicle in
                    NavigationLink(value: vehicle) {
                        VehicleCardView(vehicle: vehicle)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

