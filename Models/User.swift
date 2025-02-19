import Foundation

struct User {
    let id: UUID
    let name: String
    let email: String
    let phoneNumber: String
    var vehicles: [Vehicle] = []
}
