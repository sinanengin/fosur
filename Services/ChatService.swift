import Foundation

class ChatService {
    static let shared = ChatService()
    private let baseURL = "http://localhost:3000/api" // MongoDB API endpoint
    
    private init() {}
    
    // MARK: - Chat İşlemleri
    
    func getChats() async throws -> [Chat] {
        guard let url = URL(string: "\(baseURL)/chats") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Chat].self, from: data)
    }
    
    func getChat(id: String) async throws -> Chat {
        guard let url = URL(string: "\(baseURL)/chats/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Chat.self, from: data)
    }
    
    func createChat(title: String, type: Chat.ChatType) async throws -> Chat {
        guard let url = URL(string: "\(baseURL)/chats") else {
            throw NetworkError.invalidURL
        }
        
        let chatData = [
            "title": title,
            "type": type.rawValue
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: chatData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(Chat.self, from: data)
    }
    
    // MARK: - Mesaj İşlemleri
    
    func getMessages(chatId: String) async throws -> [ChatMessage] {
        guard let url = URL(string: "\(baseURL)/chats/\(chatId)/messages") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ChatMessage].self, from: data)
    }
    
    func sendMessage(chatId: String, content: String, type: ChatMessage.MessageType = .text) async throws -> ChatMessage {
        guard let url = URL(string: "\(baseURL)/chats/\(chatId)/messages") else {
            throw NetworkError.invalidURL
        }
        
        let messageData = [
            "content": content,
            "type": type.rawValue
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: messageData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(ChatMessage.self, from: data)
    }
    
    func uploadImage(chatId: String, image: Data) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chats/\(chatId)/upload") else {
            throw NetworkError.invalidURL
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
        return response.imageUrl
    }
}

// MARK: - Yardımcı Yapılar

struct ImageUploadResponse: Codable {
    let imageUrl: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
} 