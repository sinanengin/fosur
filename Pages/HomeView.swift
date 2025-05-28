import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack(path: $appState.navigationManager.navigationPath) {
            TabView(selection: $appState.tabSelection) {
                NewsView()
                    .tabItem {
                        Label("Haberler", systemImage: "newspaper")
                    }
                    .tag(TabItem.news)
                
                MyVehiclesView()
                    .tabItem {
                        Label("Araçlarım", systemImage: "car")
                    }
                    .tag(TabItem.myVehicles)
                
                CallUsView()
                    .tabItem {
                        Label("Bizi Çağır", systemImage: "phone")
                    }
                    .tag(TabItem.callUs)
                
                MessagesView()
                    .tabItem {
                        Label("Mesajlar", systemImage: "message")
                    }
                    .tag(TabItem.messages)
                
                ProfileView()
                    .tabItem {
                        Label("Profil", systemImage: "person")
                    }
                    .tag(TabItem.profile)
            }
            .sheet(item: $appState.navigationManager.presentedSheet) { destination in
                switch destination {
                case .auth:
                    AuthSelectionSheetView(
                        onLoginSuccess: {
                            appState.setLoggedInUser()
                            appState.navigationManager.dismissSheet()
                        },
                        onGuestContinue: {
                            appState.setGuestUser()
                            appState.navigationManager.dismissSheet()
                        },
                        hideGuestOption: false
                    )
                case .terms:
                    TermsOfServiceView()
                case .privacy:
                    PrivacyPolicyView()
                case .cityCodePicker:
                    CityCodePickerView(selectedCityCode: $appState.navigationManager.selectedCityCode)
                }
            }
            .fullScreenCover(item: $appState.navigationManager.presentedFullScreenCover) { destination in
                switch destination {
                case .brandSelection:
                    BrandSelectionView(
                        brands: vehicleBrands,
                        onSelect: { index in
                            appState.navigationManager.dismissFullScreen()
                        }
                    )
                case .modelSelection:
                    if let selectedBrand = appState.navigationManager.selectedBrand {
                        ModelSelectionView(
                            brand: selectedBrand,
                            onSelect: { model in
                                appState.navigationManager.dismissFullScreen()
                            }
                        )
                    }
                case .addVehicle:
                    AddVehicleView {
                        appState.navigationManager.dismissFullScreen()
                    }
                case .editVehicle:
                    if let vehicle = appState.navigationManager.selectedVehicle {
                        EditVehicleView(vehicle: vehicle) { updatedVehicle in
                            appState.navigationManager.dismissFullScreen()
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    HomeView()
}
