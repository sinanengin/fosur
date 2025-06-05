import Foundation

struct Chat: Identifiable, Codable {
    let id: String
    let userId: String
    let title: String
    let lastMessage: String
    let timestamp: Date
    let isRead: Bool
    let participants: [String]
    let type: ChatType
    
    enum ChatType: String, Codable {
        case support
        case service
        case custom
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let chatId: String
    let senderId: String
    let content: String
    let imageUrl: String?
    let timestamp: Date
    let isRead: Bool
    let type: MessageType
    
    enum MessageType: String, Codable {
        case text
        case image
        case system
    }
}

// MongoDB için ObjectId dönüşümleri
extension String {
    var toObjectId: String {
        return self
    }
}

extension Date {
    var toISODate: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    static func fromISO(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: string)
    }
} 