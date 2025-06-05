import SwiftUI

class AppState: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User? = nil
    @Published var navigationManager = NavigationManager()
    @Published var tabSelection: TabItem = .callUs
    @Published var showAddVehicleView = false // EKLEDİK
    @Published var showAuthSheet = false // Giriş yaparken açılan sheet
    @Published var isFromOnboarding = false // Onboarding'den gelip gelmediğini takip eder

    func setGuestUser() {
        self.isUserLoggedIn = false
        self.currentUser = User(
            id: UUID(),
            name: "Misafir",
            surname: "Kullanıcı",
            email: "misafir@fosur.com",
            phoneNumber: "Yok",
            profileImage: nil,
            vehicles: []
        )
    }

    func setLoggedInUser() {
        self.isUserLoggedIn = true
        self.currentUser = User(
            id: UUID(),
            name: "Deneme",
            surname: "Kullanıcı",
            email: "deneme@fosur.com",
            phoneNumber: "5551234567",
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
}
