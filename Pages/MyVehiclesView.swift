import SwiftUI

struct MyVehiclesView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddVehicle = false
    @State private var selectedVehicle: Vehicle?

    var body: some View {
        NavigationStack {
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
            .fullScreenCover(isPresented: $showAddVehicle) {
                AddVehicleView {
                    showAddVehicle = false
                }
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedVehicle != nil },
                set: { isActive in
                    if !isActive {
                        selectedVehicle = nil
                    }
                }
            )) {
                if let vehicle = selectedVehicle {
                    MyVehicleDetailView(vehicle: vehicle)
                }
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

    private var guestPromptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Araç ekleyebilmek için önce giriş yapmalısın.")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.gray)

            Button("Giriş Yap") {
                // Giriş ekranı gösterimi burada olacak
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
                    Button {
                        selectedVehicle = vehicle
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
