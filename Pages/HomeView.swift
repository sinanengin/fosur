import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
            TabView(selection: $appState.tabSelection) {
            NavigationStack {
                NewsView()
            }
                    .tabItem {
                        Label("Haberler", systemImage: "newspaper")
                    }
                    .tag(TabItem.news)
                
            NavigationStack(path: $appState.navigationManager.navigationPath) {
                MyVehiclesView()
                    .navigationDestination(for: Vehicle.self) { vehicle in
                        MyVehicleDetailView(vehicle: vehicle)
                    }
            }
                    .tabItem {
                        Label("Araçlarım", systemImage: "car")
                    }
                    .tag(TabItem.myVehicles)
                
            NavigationStack {
                CallUsView()
            }
                    .tabItem {
                        Label("Bizi Çağır", systemImage: "phone")
                    }
                    .tag(TabItem.callUs)
                
            NavigationStack {
                MessagesView()
            }
                    .tabItem {
                        Label("Mesajlar", systemImage: "message")
                    }
                    .tag(TabItem.messages)
                
            NavigationStack {
                ProfileView()
            }
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
                        onPhoneLogin: {
                            // Artık NavigationManager sistemi kullanıyoruz
                            // Bu callback artık kullanılmayacak
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
                case .phoneLogin:
                    PhoneLoginView()
                        .environmentObject(appState)
                        .interactiveDismissDisabled()
                }
            }
        // Sipariş akışı fullScreenCover'ları ayrı ayrı
        .fullScreenCover(isPresented: $appState.showDateTimeSelection) {
            DateTimeSelectionView()
                .environmentObject(appState)
        }
        .fullScreenCover(isPresented: $appState.showOrderSummary) {
            OrderSummaryView()
                .environmentObject(appState)
        }
        .fullScreenCover(isPresented: $appState.showPayment) {
            PaymentView()
                .environmentObject(appState)
        }
    }
}


#Preview {
    HomeView()
}
