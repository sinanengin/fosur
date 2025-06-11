//
//  ServicesService.swift
//  fosur
//
//  Created by Sinan Engin Yıldız on 11.06.2025.
//

import Foundation

// MARK: - Service Models
struct ServiceResponse: Codable {
    let data: ServiceData
}

struct ServiceData: Codable {
    let resourceUrn: String
    let name: String
    let price: Double
    let details: String
    let id: String
    let state: String
    let images: [String]
    let domain: String
}

// MARK: - Services Service
class ServicesService: ObservableObject {
    static let shared = ServicesService()
    
    private let baseURL = "http://localhost:8080"
    private let authService = AuthService.shared
    
    @Published var isLoading = false
    @Published var cachedServices: [ServiceData] = []
    
    private init() {}
    
    func fetchWashPackages() async throws -> [ServiceData] {
        print("🛠️ ServicesService: fetchWashPackages başladı")
        
        // Cache varsa kullan
        if !cachedServices.isEmpty {
            print("✅ Cache'den \(cachedServices.count) hizmet döndürülüyor")
            return cachedServices
        }
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/wash-packages") else {
            await MainActor.run { self.isLoading = false }
            throw URLError(.badURL)
        }
        
        print("🌐 Request URL: \(url)")
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // AuthService'ten header al
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
                print("🔑 Header: \(key) = \(value)")
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw URLError(.badServerResponse)
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard httpResponse.statusCode == 200 else {
                await MainActor.run { self.isLoading = false }
                throw URLError(.badServerResponse)
            }
            
            let serviceResponses = try JSONDecoder().decode([ServiceResponse].self, from: data)
            let services = serviceResponses.map { $0.data }
            
            await MainActor.run {
                self.cachedServices = services
                self.isLoading = false
            }
            
            print("✅ \(services.count) hizmet başarıyla alındı ve cache'lendi")
            return services
            
        } catch {
            await MainActor.run { self.isLoading = false }
            
            // URLError cancelled hatasını farklı handle et
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ fetchWashPackages: Request cancelled")
                throw URLError(.cancelled)
            } else {
                print("❌ fetchWashPackages Error: \(error)")
                throw error
            }
        }
    }
    
    func clearCache() {
        cachedServices = []
    }
}
