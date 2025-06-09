//
//  CustomerService.swift
//  fosur
//
//  Created by Sinan Engin Yıldız on 10.06.2025.
//

import Foundation

// MARK: - Customer Request/Response Models
struct CreateCustomerRequest: Codable {
    let email: String?
    let phone: String
    let name: CustomerName
    let avatarUrl: String?
}

struct CustomerName: Codable {
    let givenName: String
    let lastName: String
    let fullName: String
}

struct CreateCustomerResponse: Codable {
    let data: CustomerData
}

struct CustomerData: Codable {
    let resourceUrn: String
    let address: String?
    let email: String?
    let phone: String
    let name: CustomerName
    let avatarUrl: String?
    let id: String
    let state: String
    let owner: String
    let domain: String
}

// MARK: - Customer Errors
enum CustomerError: Error, LocalizedError {
    case noAuthToken
    case networkError
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAuthToken:
            return "Giriş yapmanız gerekiyor"
        case .networkError:
            return "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı"
        case .serverError(let message):
            return message
        }
    }
}

// MARK: - CustomerService
class CustomerService {
    static let shared = CustomerService()
    
    private let baseURL = "http://localhost:8080"
    private let authService = AuthService.shared
    
    private init() {}
    
    // MARK: - Create Customer
    func createCustomer(givenName: String, lastName: String, email: String) async throws -> CustomerData {
        print("👤 CustomerService: createCustomer başladı")
        print("👤 Ad: \(givenName)")
        print("👤 Soyad: \(lastName)")
        print("📧 Email: \(email)")
        
        // Auth kontrolü
        guard let userDetails = authService.currentUser else {
            print("❌ User details bulunamadı")
            throw CustomerError.noAuthToken
        }
        
        // Phone numarasını temizle (+90 prefix'ini kaldır)
        let cleanPhone = userDetails.phoneNumber.replacingOccurrences(of: "+90", with: "")
        print("📱 Phone: \(cleanPhone)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/customers") else {
            print("❌ URL oluşturulamadı")
            throw CustomerError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        // Request body oluştur
        let customerName = CustomerName(
            givenName: givenName,
            lastName: lastName,
            fullName: "\(givenName) \(lastName)"
        )
        
        let requestBody = CreateCustomerRequest(
            email: email.isEmpty ? nil : email,
            phone: cleanPhone,
            name: customerName,
            avatarUrl: nil
        )
        
        do {
            // JSON body'yi encode et
            let jsonData = try JSONEncoder().encode(requestBody)
            
            print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
            // Auth headers kontrol et
            let authHeaders = authService.getAuthHeaders()
            print("🔐 Auth Headers: \(authHeaders)")
            
            // Authenticated request at
            let (data, response) = try await authService.makeAuthenticatedRequest(
                to: url,
                method: "POST",
                body: jsonData
            )
            
            print("📥 Response alındı")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "empty")")
            
            // HTTP status code kontrol et
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ HTTPURLResponse cast edilemedi")
                throw CustomerError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📊 Response Headers: \(httpResponse.allHeaderFields)")
            
            // 200-201 arası başarılı
            guard (200...201).contains(httpResponse.statusCode) else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw CustomerError.serverError("Customer oluşturma başarısız: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let customerResponse = try JSONDecoder().decode(CreateCustomerResponse.self, from: data)
            print("✅ JSON başarıyla parse edildi")
            print("👤 Customer ID: \(customerResponse.data.id)")
            print("📧 Customer Email: \(customerResponse.data.email ?? "none")")
            
            return customerResponse.data
            
        } catch let error as CustomerError {
            print("❌ CustomerError: \(error.localizedDescription)")
            throw error
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("❌ Missing key: \(key) in \(context)")
            case .typeMismatch(let type, let context):
                print("❌ Type mismatch: \(type) in \(context)")
            case .valueNotFound(let type, let context):
                print("❌ Value not found: \(type) in \(context)")
            case .dataCorrupted(let context):
                print("❌ Data corrupted: \(context)")
            @unknown default:
                print("❌ Unknown decoding error")
            }
            throw CustomerError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            print("❌ Error Type: \(type(of: error))")
            throw CustomerError.networkError
        }
    }
}
