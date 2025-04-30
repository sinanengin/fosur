import Foundation

struct User {
    let id: UUID
    let name: String
    let surname: String
    let email: String
    let phoneNumber: String
    let profileImage: URL?
    var vehicles: [Vehicle] = []
}
