import SwiftUI

struct MyVehiclesView: View {
    @EnvironmentObject var appState: AppState
    @State private var path = NavigationPath()
    @State private var showAuthSheet = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Text("Araçlarım")
                    .font(CustomFont.bold(size: 28))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.top)

                if !appState.isUserLoggedIn {
                    VStack(spacing: 12) {
                        Text("Araçlarınızı görüntüleyebilmek için lütfen giriş yapın.")
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
                } else {
                    if appState.currentUser?.vehicles.isEmpty ?? true {
                        EmptyVehicleView {
                            path.append("addVehicle")
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(appState.currentUser?.vehicles ?? []) { vehicle in
                                    VehicleCardView(vehicle: vehicle)
                                }

                                EmptyVehicleView {
                                    path.append("addVehicle")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "addVehicle" {
                    AddVehicleView()
                }
            }
            .sheet(isPresented: $showAuthSheet) {
                AuthSelectionSheetView(
                    onLoginSuccess: {
                        appState.setLoggedInUser()
                    },
                    onGuestContinue: {},
                    hideGuestOption: true
                )
            }
            .background(Color("BackgroundColor"))
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    MyVehiclesView()
        .environmentObject(AppState())
}
