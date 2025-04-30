import Foundation

struct ChatBubble: Identifiable {
    let id = UUID()
    let content: String
    let isSentByUser: Bool
}
