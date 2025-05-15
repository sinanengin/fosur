import SwiftUI

struct MyVehiclesView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddVehicle = false
    @State private var showAuthSheet = false
    @SceneStorage("MyVehiclesNavigationPath") private var navigationPathData: Data = Data()
    @State private var navigationPath: [Vehicle] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(navigationPath) {
                navigationPathData = encoded
            }
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
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

            // Add Vehicle Sayfası
            .fullScreenCover(isPresented: $showAddVehicle) {
                AddVehicleView {
                    showAddVehicle = false
                }
            }

            // Araç Detay Sayfası
            .navigationDestination(for: Vehicle.self) { vehicle in
                MyVehicleDetailView(vehicle: vehicle)
            }

            // Giriş ekranı
            .sheet(isPresented: $showAuthSheet) {
                AuthSelectionSheetView(
                    onLoginSuccess: {
                        appState.setLoggedInUser()
                        showAuthSheet = false
                    },
                    onGuestContinue: {
                        appState.setGuestUser()
                        showAuthSheet = false
                    },
                    hideGuestOption: false
                )
                .presentationDetents([.fraction(0.55)])
                .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            if let decoded = try? JSONDecoder().decode([Vehicle].self, from: navigationPathData) {
                navigationPath = decoded
            } else {
                navigationPath = []
            }
        }
        .onChange(of: appState.tabSelection) {
            if appState.tabSelection == .vehicles {
                navigationPath = []
            }
        }
    }

    // MARK: Header
    private var headerView: some View {
        HStack {
            Text("Araçlarım")
                .font(CustomFont.bold(size: 28))
            Spacer()
            if appState.isUserLoggedIn {
                Button {
                    showAddVehicle = true
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

    // MARK: Giriş Yapmamış Ekranı
    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Araç ekleyebilmek için önce giriş yapmalısın.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)

            Button("Giriş Yap") {
                showAuthSheet = true
            }
            .font(CustomFont.medium(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.logo)
            .cornerRadius(10)
            .padding(.horizontal)
            Spacer()
        }
    }

    // MARK: Araç Yok Ekranı
    private var noVehicleView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Henüz eklenmiş aracınız yok.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)
            Spacer()
        }
    }

    // MARK: Araç Listesi
    private var vehicleListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(appState.currentUser?.vehicles ?? []) { vehicle in
                    Button {
                        navigationPath.append(vehicle)
                    } label: {
                        VehicleCardView(vehicle: vehicle)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}
