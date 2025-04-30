import Foundation

struct ChatPreview: Identifiable, Equatable {
    let id: UUID
    let senderName: String
    let senderTitle: String
    let lastMessage: String
    let time: String
}
