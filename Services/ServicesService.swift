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

// MARK: - Frontend Service Model
struct Service: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let images: [String]
    
    // ServiceData'dan Service'e dönüştürme
    init(from serviceData: ServiceData) {
        self.id = serviceData.id
        self.title = serviceData.name
        self.description = serviceData.details
        self.price = serviceData.price
        self.images = serviceData.images
    }
    
    // Manuel oluşturma
    init(id: String, title: String, description: String, price: Double, images: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.images = images
    }
    
    // Service'den ServiceData'ya dönüştürme
    func toServiceData() -> ServiceData {
        return ServiceData(
            resourceUrn: "",
            name: self.title,
            price: self.price,
            details: self.description,
            id: self.id,
            state: "active",
            images: self.images,
            domain: ""
        )
    }
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
    
    // MARK: - Get Services for Order
    func getServicesForOrder(orderId: String) async throws -> [ServiceData] {
        print("🛠️ ServicesService: getServicesForOrder başladı - Order ID: \(orderId)")
        
        // Önce tüm hizmetleri al
        let allServices = try await fetchWashPackages()
        
        // Order'dan washPackage ID'lerini al (bu fonksiyon OrderDetailView'den çağrılıyor)
        // Gerçek implementasyonda order detayından washPackage ID'leri alınacak
        // Şimdilik tüm hizmetleri döndürelim
        
        print("✅ \(allServices.count) hizmet döndürülüyor")
        return allServices
    }
    
    // MARK: - Get Service by ID
    func getServiceById(_ serviceId: String) async throws -> ServiceData? {
        let allServices = try await fetchWashPackages()
        let cleanId = serviceId.replacingOccurrences(of: "washpackage:", with: "")
        
        return allServices.first { service in
            service.id == cleanId || service.id == serviceId
        }
    }
}
