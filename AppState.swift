import SwiftUI

class AppState: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User? = nil

    @Published var tabSelection: Tab = .home
    @Published var showAddVehicleView = false // EKLEDİK
    @Published var showAuthSheet = false // Giriş yaparken açılan sheet

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
            vehicles: []
        )
    }
}
