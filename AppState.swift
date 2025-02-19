import SwiftUI

class AppState: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User? = nil

    @Published var showAddVehicleView = false // EKLEDİK
    @Published var showAuthSheet = false // Giriş yaparken açılan sheet

    func setGuestUser() {
        self.isUserLoggedIn = false
        self.currentUser = User(
            id: UUID(),
            name: "Misafir Kullanıcı",
            email: "misafir@fosur.com",
            phoneNumber: "Yok",
            vehicles: []
        )
    }

    func setLoggedInUser() {
        self.isUserLoggedIn = true
        self.currentUser = User(
            id: UUID(),
            name: "Deneme Kullanıcı",
            email: "deneme@fosur.com",
            phoneNumber: "5551234567",
            vehicles: []
        )
    }
}
