import Foundation

struct User {
    let id: UUID
    var name: String
    var surname: String
    var email: String
    var phoneNumber: String
    let profileImage: URL?
    var vehicles: [Vehicle] = []
}
