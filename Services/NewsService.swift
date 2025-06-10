//
//  NewsService.swift
//  fosur
//
//  Created by Sinan Engin Yıldız on 10.06.2025.
//

import Foundation

// MARK: - News/Announcement API Models
struct AnnouncementListResponse: Codable {
    let data: AnnouncementData
}

struct AnnouncementDetailResponse: Codable {
    let data: AnnouncementData
}

struct AnnouncementData: Codable, Identifiable {
    let resourceUrn: String
    let type: String
    let date: String
    let title: String
    let description: String
    let id: String
    let images: [String]
    let state: String
    let domain: String
    
    // MARK: - Computed Properties
    var displayDate: String {
        NewsService.shared.formatDate(date)
    }
    
    var imageUrl: String {
        // Backend'den gelen image URL'ini döndür, boşsa placeholder kullan
        return images.first ?? "news_placeholder"
    }
    
    var categoryDisplayName: String {
        switch type.lowercased() {
        case "campaign":
            return "Kampanya"
        case "service_update":
            return "Hizmet Güncellesi"
        case "system_alert":
            return "Sistem Uyarısı"
        case "feature_announcement":
            return "Özellik Duyurusu"
        default:
            return "Duyuru"
        }
    }
}

// MARK: - News Errors
enum NewsError: Error, LocalizedError {
    case noAuthToken
    case networkError
    case invalidResponse
    case serverError(String)
    case notFound
    
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
        case .notFound:
            return "Haber bulunamadı"
        }
    }
}

// MARK: - NewsService
class NewsService: ObservableObject {
    static let shared = NewsService()
    
    private let baseURL = "http://localhost:8080"
    private let authService = AuthService.shared
    
    @Published var announcements: [AnnouncementData] = []
    @Published var isLoading = false
    
    private init() {}
    
    // MARK: - Fetch All Announcements
    func fetchAnnouncements() async throws -> [AnnouncementData] {
        print("📰 NewsService: fetchAnnouncements başladı")
        
        // Loading state'i başlat
        await MainActor.run {
            self.isLoading = true
        }
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/announcements") else {
            print("❌ URL oluşturulamadı")
            await MainActor.run {
                self.isLoading = false
            }
            throw NewsError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        do {
            // Authenticated request at
            let (data, response) = try await authService.makeAuthenticatedRequest(to: url)
            
            print("📥 Response alındı")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "empty")")
            
            // HTTP status code kontrol et
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ HTTPURLResponse cast edilemedi")
                throw NewsError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            // 200 OK bekliyoruz
            guard httpResponse.statusCode == 200 else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw NewsError.serverError("Haberler alınamadı: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let announcementResponses = try JSONDecoder().decode([AnnouncementListResponse].self, from: data)
            print("✅ JSON başarıyla parse edildi - \(announcementResponses.count) haber")
            
            // AnnouncementData'ları direkt döndür
            let announcements = announcementResponses.map { $0.data }
            
            // UI güncellemesi main thread'de
            await MainActor.run {
                self.announcements = announcements
                self.isLoading = false
            }
            
            return announcements
            
        } catch let error as NewsError {
            print("❌ NewsError: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
            }
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
            await MainActor.run {
                self.isLoading = false
            }
            throw NewsError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            print("❌ Error Type: \(type(of: error))")
            await MainActor.run {
                self.isLoading = false
            }
            throw NewsError.networkError
        }
    }
    
    // MARK: - Fetch Single Announcement
    func fetchAnnouncementDetail(id: String) async throws -> AnnouncementData {
        print("📰 NewsService: fetchAnnouncementDetail başladı - ID: \(id)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/announcements/\(id)") else {
            print("❌ URL oluşturulamadı")
            throw NewsError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        do {
            // Authenticated request at
            let (data, response) = try await authService.makeAuthenticatedRequest(to: url)
            
            print("📥 Response alındı")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "empty")")
            
            // HTTP status code kontrol et
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ HTTPURLResponse cast edilemedi")
                throw NewsError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            // Status code kontrolü
            switch httpResponse.statusCode {
            case 200:
                break // Başarılı
            case 404:
                throw NewsError.notFound
            default:
                throw NewsError.serverError("Haber detayı alınamadı: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let announcementResponse = try JSONDecoder().decode(AnnouncementDetailResponse.self, from: data)
            print("✅ JSON başarıyla parse edildi")
            
            // AnnouncementData'yı direkt döndür
            return announcementResponse.data
            
        } catch let error as NewsError {
            print("❌ NewsError: \(error.localizedDescription)")
            throw error
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw NewsError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            throw NewsError.networkError
        }
    }
    
    // MARK: - Helper Methods
    func formatDate(_ isoString: String) -> String {
        // Backend format: "2025-06-09T11:14:11.887Z"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = inputFormatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd.MM.yyyy"
            outputFormatter.locale = Locale(identifier: "tr_TR")
            return outputFormatter.string(from: date)
        }
        
        // Fallback: ISO8601DateFormatter dene
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: isoString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd.MM.yyyy"
            outputFormatter.locale = Locale(identifier: "tr_TR")
            return outputFormatter.string(from: date)
        }
        
        return isoString // Parse edilemezse original string döndür
    }
}
