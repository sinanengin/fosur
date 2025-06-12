//
//  OrderService.swift
//  fosur
//
//  Created by Sinan Engin Yıldız on 12.06.2025.
//

import Foundation

// MARK: - Order Models
struct Order: Identifiable, Codable {
    let id: String
    let address: OrderAddress
    let car: String
    let reservationTime: String
    let washPackages: [String]
    let owner: String
    let state: OrderState
    let createdAt: String?
    let updatedAt: String?
    let totalPrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case address, car, reservationTime, washPackages, owner, state, createdAt, updatedAt, totalPrice
    }
}

struct OrderAddress: Codable {
    let id: String?
    let name: String
    let formattedAddress: String
    let latitude: Double
    let longitude: Double
    let street: String
    let neighborhood: String
    let district: String
    let city: String
    let province: String
    let postalCode: String
    let country: String
}

enum OrderState: String, Codable, CaseIterable {
    case pendingApproval = "PENDING_APPROVAL"
    case approved = "APPROVED"
    case assigned = "ASSIGNED"
    case inProgress = "IN_PROGRESS"
    case washed = "WASHED"
    case completed = "COMPLETED"
    case canceled = "CANCELED"
    
    // API lowercase gönderiyor olabilir
    case pendingApprovalLower = "pending_approval"
    case approvedLower = "approved"
    case assignedLower = "assigned"
    case inProgressLower = "in_progress"
    case washedLower = "washed"
    case completedLower = "completed"
    case canceledLower = "canceled"
    
    var displayName: String {
        switch self {
        case .pendingApproval, .pendingApprovalLower: return "Onay Bekliyor"
        case .approved, .approvedLower: return "Onaylandı"
        case .assigned, .assignedLower: return "Atandı"
        case .inProgress, .inProgressLower: return "Devam Ediyor"
        case .washed, .washedLower: return "Yıkandı"
        case .completed, .completedLower: return "Tamamlandı"
        case .canceled, .canceledLower: return "İptal Edildi"
        }
    }
    
    var color: String {
        switch self {
        case .pendingApproval, .pendingApprovalLower: return "orange"
        case .approved, .approvedLower: return "blue"
        case .assigned, .assignedLower: return "purple"
        case .inProgress, .inProgressLower: return "yellow"
        case .washed, .washedLower: return "green"
        case .completed, .completedLower: return "green"
        case .canceled, .canceledLower: return "red"
        }
    }
}

struct CreateOrderRequest: Codable {
    let address: OrderAddress
    let car: String
    let reservationTime: String
    let washPackages: [String]
    let owner: String
    
    // API'nin beklediği format farklı olabilir, alternatif field isimleri:
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case car = "car"
        case reservationTime = "reservationTime"
        case washPackages = "washPackages"
        case owner = "owner"
    }
}

struct UpdateOrderStateRequest: Codable {
    let state: String
}

struct OrderResponse: Codable {
    let success: Bool?
    let data: Order?
    let message: String?
    
    // API bazen sadece {"data": {...}} formatında dönebilir
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // success field'i optional
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
        
        // data field'i var mı kontrol et
        if container.contains(.data) {
            data = try container.decodeIfPresent(Order.self, forKey: .data)
        } else {
            // Eğer data field'i yoksa, tüm response'u Order olarak parse etmeye çalış
            data = try Order(from: decoder)
        }
        
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
    enum CodingKeys: String, CodingKey {
        case success, data, message
    }
}

struct OrdersResponse: Codable {
    let success: Bool?
    let data: [Order]?
    let message: String?
    
    // API Array<{data: Order}> formatında dönüyor
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // success field'i optional
        success = try container.decodeIfPresent(Bool.self, forKey: .success)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // Önce normal data field'ini dene
        if container.contains(.data) {
            data = try container.decodeIfPresent([Order].self, forKey: .data)
        } else {
            // Eğer data field'i yoksa, tüm response'u Order wrapper array olarak parse et
            let orderWrappers = try [OrderWrapper](from: decoder)
            data = orderWrappers.map { $0.data }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case success, data, message
    }
}

// API'nin gerçek formatı için wrapper
struct OrderWrapper: Codable {
    let data: Order
}

// MARK: - OrderService
class OrderService: ObservableObject {
    static let shared = OrderService()
    private let baseURL = "http://localhost:8080"
    
    private init() {}
    
    // MARK: - Create Order
    func createOrder(
        address: CustomerAddress,
        car: Vehicle,
        reservationTime: Date,
        washPackages: [ServiceData],
        customerId: String
    ) async throws -> Order {
        guard let url = URL(string: "\(baseURL)/orders") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bearer token ekle
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Auth Token: \(token.prefix(20))...")
        } else {
            print("⚠️ Auth token bulunamadı!")
        }
        
        // ISO 8601 format ile tarih
        let isoFormatter = ISO8601DateFormatter()
        let reservationTimeISO = isoFormatter.string(from: reservationTime)
        
        let orderAddress = OrderAddress(
            id: address.id,
            name: address.name,
            formattedAddress: address.formattedAddress,
            latitude: address.latitude,
            longitude: address.longitude,
            street: address.street,
            neighborhood: address.neighborhood,
            district: address.district,
            city: address.city,
            province: address.province,
            postalCode: address.postalCode,
            country: address.country
        )
        
        let createRequest = CreateOrderRequest(
            address: orderAddress,
            car: formatCarId(car.apiId ?? car.id.uuidString),
            reservationTime: reservationTimeISO,
            washPackages: washPackages.map { formatWashPackageId($0.id) },
            owner: formatCustomerId(customerId)
        )
        
        // Debug: Request payload'ını logla
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestData = try encoder.encode(createRequest)
        if let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 Create Order Request:")
            print(requestString)
            print("🚗 Car ID being sent: \(formatCarId(car.apiId ?? car.id.uuidString))")
            print("📋 Wash Packages: \(washPackages.map { formatWashPackageId($0.id) })")
            print("👤 Customer ID: \(formatCustomerId(customerId))")
        }
        
        request.httpBody = try JSONEncoder().encode(createRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📦 Create Order Response: \(httpResponse.statusCode)")
        
        // Response body'yi logla
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Response Body: \(responseString)")
        }
        
        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: data)
            
            if let order = orderResponse.data {
                print("✅ Sipariş oluşturuldu: \(order.id)")
                return order
            } else {
                let errorMsg = orderResponse.message ?? "Sipariş verisi alınamadı"
                throw NSError(domain: "OrderService", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg])
            }
        } else {
            let errorResponse = try? JSONDecoder().decode(OrderResponse.self, from: data)
            let errorMsg = errorResponse?.message ?? "Sipariş oluşturulamadı"
            throw NSError(domain: "OrderService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    // MARK: - Get Orders
    func getOrders(customerId: String, state: OrderState? = nil) async throws -> [Order] {
        let formattedCustomerId = formatCustomerId(customerId)
        var urlString = "\(baseURL)/orders?query=owner==\(formattedCustomerId)"
        
        if let state = state {
            // State filtresi için ayrı query parametresi
            urlString = "\(baseURL)/orders?query=state==\(state.rawValue.uppercased())"
        }
        
        print("🔗 Get Orders URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Bearer token ekle
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📦 Get Orders Response: \(httpResponse.statusCode)")
        
        // Response body'yi logla
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Get Orders Response Body: \(responseString)")
        }
        
        if httpResponse.statusCode == 200 {
            // API direkt array döndürüyor: [{"data": Order}, {"data": Order}]
            let orderWrappers = try JSONDecoder().decode([OrderWrapper].self, from: data)
            let orders = orderWrappers.map { $0.data }
            
            print("✅ \(orders.count) sipariş başarıyla parse edildi")
            return orders
        } else {
            let errorResponse = try? JSONDecoder().decode(OrdersResponse.self, from: data)
            throw NSError(domain: "OrderService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse?.message ?? "Siparişler alınamadı"])
        }
    }
    
    // MARK: - Update Order State
    func updateOrderState(orderId: String, newState: OrderState) async throws -> Order {
        guard let url = URL(string: "\(baseURL)/orders/\(orderId)/state") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Bearer token ekle
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // State'i lowercase olarak gönder
        let stateValue = newState.rawValue.lowercased()
        let updateRequest = UpdateOrderStateRequest(state: stateValue)
        
        // Debug: Request payload'ını logla
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let requestData = try encoder.encode(updateRequest)
        if let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 Update Order State Request:")
            print(requestString)
            print("🔄 State being sent: \(stateValue)")
        }
        
        request.httpBody = try JSONEncoder().encode(updateRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📦 Update Order State Response: \(httpResponse.statusCode)")
        
        // Response body'yi logla
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Update State Response Body: \(responseString)")
        }
        
        if httpResponse.statusCode == 200 {
            let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: data)
            
            if let order = orderResponse.data {
                print("✅ Sipariş durumu güncellendi: \(order.state.displayName)")
                return order
            } else {
                throw NSError(domain: "OrderService", code: 0, userInfo: [NSLocalizedDescriptionKey: orderResponse.message ?? "Bilinmeyen hata"])
            }
        } else {
            let errorResponse = try? JSONDecoder().decode(OrderResponse.self, from: data)
            let errorMsg = errorResponse?.message ?? "Sipariş durumu güncellenemedi (HTTP \(httpResponse.statusCode))"
            throw NSError(domain: "OrderService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }
    
    // MARK: - Test Connection
    func testConnection() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            print("❌ Invalid URL")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        // Bearer token ekle
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Health Check with Token: \(token.prefix(20))...")
        } else {
            print("⚠️ Health check - Auth token bulunamadı!")
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🏥 Health Check Response: \(httpResponse.statusCode)")
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            print("❌ Connection test failed: \(error)")
            return false
        }
    }
    
    // MARK: - Check Existing Orders
    func hasActiveOrderForVehicle(customerId: String, vehicleId: String) async throws -> Bool {
        do {
            let orders = try await getOrders(customerId: customerId)
            
            let activeStates: [OrderState] = [
                .pendingApproval, .pendingApprovalLower,
                .approved, .approvedLower,
                .assigned, .assignedLower,
                .inProgress, .inProgressLower
            ]
            let formattedVehicleId = formatCarId(vehicleId)
            
            let activeOrder = orders.first { order in
                activeStates.contains(order.state) && order.car == formattedVehicleId
            }
            
            if let existingOrder = activeOrder {
                print("⚠️ Bu araç için aktif sipariş bulundu: \(existingOrder.id) - Durum: \(existingOrder.state.displayName)")
                return true
            }
            
            return false
        } catch {
            print("❌ Aktif sipariş kontrolü sırasında hata: \(error)")
            // Hata durumunda false döndür ki sipariş oluşturma engellenmesin
            return false
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatCarId(_ carId: String) -> String {
        // Eğer zaten prefix varsa, olduğu gibi döndür
        if carId.hasPrefix("car:") {
            return carId
        }
        return "car:\(carId)"
    }
    
    private func formatWashPackageId(_ packageId: String) -> String {
        // Eğer zaten prefix varsa, olduğu gibi döndür
        if packageId.hasPrefix("washpackage:") {
            return packageId
        }
        return "washpackage:\(packageId)"
    }
    
    private func formatCustomerId(_ customerId: String) -> String {
        // Eğer zaten prefix varsa, olduğu gibi döndür
        if customerId.hasPrefix("customer:") {
            return customerId
        }
        return "customer:\(customerId)"
    }
}
