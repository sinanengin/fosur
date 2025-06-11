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

// MARK: - Address Models
struct CustomerAddress: Identifiable, Codable, Equatable {
    let id: String
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
    
    // Legacy Address ile uyumluluk için
    var title: String { name }
    var fullAddress: String { formattedAddress }
    
    static func == (lhs: CustomerAddress, rhs: CustomerAddress) -> Bool {
        lhs.id == rhs.id
    }
}

struct AddAddressRequest: Codable {
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

struct UpdateAddressRequest: Codable {
    let id: String
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

struct DeleteAddressRequest: Codable {
    let id: String
}

struct CustomerWithAddressesResponse: Codable {
    let data: CustomerWithAddresses
}

struct CustomerWithAddresses: Codable {
    let resourceUrn: String
    let addresses: [CustomerAddress]
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
            
            // Customer ID'yi AuthService'e kaydet
            authService.saveCustomerId(customerResponse.data.id)
            
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
    
    // MARK: - Search Customers
    func searchCustomers(userId: String) async throws -> [CustomerData] {
        print("🔍 CustomerService: searchCustomers başladı - User ID: \(userId)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/customers?query=owner==user:\(userId)") else {
            print("❌ URL oluşturulamadı")
            throw CustomerError.networkError
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
                throw CustomerError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📊 Response Headers: \(httpResponse.allHeaderFields)")
            
            // 200 başarılı
            guard httpResponse.statusCode == 200 else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw CustomerError.serverError("Customer arama başarısız: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et - API bir array döndürüyor
            print("⚙️ JSON parsing başlıyor...")
            let customerResponses = try JSONDecoder().decode([CreateCustomerResponse].self, from: data)
            let customers = customerResponses.map { $0.data }
            
            print("✅ JSON başarıyla parse edildi")
            print("👥 Bulunan customer sayısı: \(customers.count)")
            
            return customers
            
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
    
    // MARK: - Helper Methods
    
    // FormattedAddress'i parse ederek ayrı alanları çıkar
    private func parseFormattedAddress(_ formattedAddress: String) -> (street: String, neighborhood: String, district: String, city: String, province: String, postalCode: String, country: String) {
        print("📍 parseFormattedAddress: \(formattedAddress)")
        
        // Format: "21, Serbest Sk., Sefaköy, Küçükçekmece, İstanbul, 34295, Türkiye"
        let components = formattedAddress.components(separatedBy: ", ")
        print("📍 Parsed components: \(components)")
        
        var street = ""
        var neighborhood = ""
        var district = ""
        var city = ""
        var province = ""
        var postalCode = ""
        var country = "Türkiye"
        
        if components.count >= 7 {
            // Tam format: [kapı no, sokak, mahalle, ilçe, şehir, postal code, ülke]
            street = "\(components[0]), \(components[1])" // "21, Serbest Sk."
            neighborhood = components[2] // "Sefaköy"
            district = components[3] // "Küçükçekmece"
            city = components[4] // "İstanbul"
            province = components[4] // İstanbul hem city hem province
            postalCode = components[5] // "34295"
            country = components[6] // "Türkiye"
        } else if components.count >= 6 {
            // Format: [kapı no, sokak, mahalle, ilçe, şehir, postal code]
            street = "\(components[0]), \(components[1])"
            neighborhood = components[2]
            district = components[3]
            city = components[4]
            province = components[4]
            postalCode = components[5]
        } else if components.count >= 5 {
            // Format: [kapı no, sokak, mahalle, ilçe, şehir]
            street = "\(components[0]), \(components[1])"
            neighborhood = components[2]
            district = components[3]
            city = components[4]
            province = components[4]
        } else {
            // Eksik format - sadece mevcut olanları kullan
            if components.count >= 2 {
                street = "\(components[0]), \(components[1])"
            }
            if components.count >= 3 {
                neighborhood = components[2]
            }
            if components.count >= 4 {
                district = components[3]
            }
            if components.count >= 5 {
                city = components[4]
                province = components[4]
            }
        }
        
        print("📍 Parsed result:")
        print("   Street: \(street)")
        print("   Neighborhood: \(neighborhood)")
        print("   District: \(district)")
        print("   City: \(city)")
        print("   Province: \(province)")
        print("   PostalCode: \(postalCode)")
        print("   Country: \(country)")
        
        return (street, neighborhood, district, city, province, postalCode, country)
    }
    
    // MARK: - Address Management
    
    // Get Customer Addresses
    func getCustomerAddresses() async throws -> [CustomerAddress] {
        print("📍 CustomerService: getCustomerAddresses başladı")
        
        // Customer ID kontrolü
        guard let customerId = authService.getCurrentCustomerId() else {
            print("❌ Customer ID bulunamadı")
            throw CustomerError.noAuthToken
        }
        
        print("👤 Customer ID: \(customerId)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/customers/\(customerId)") else {
            print("❌ URL oluşturulamadı")
            throw CustomerError.networkError
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
                throw CustomerError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw CustomerError.serverError("Adresler alınamadı: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let customerResponse = try JSONDecoder().decode(CustomerWithAddressesResponse.self, from: data)
            
            print("✅ JSON başarıyla parse edildi")
            print("📍 Bulunan adres sayısı: \(customerResponse.data.addresses.count)")
            
            return customerResponse.data.addresses
            
        } catch let error as CustomerError {
            print("❌ CustomerError: \(error.localizedDescription)")
            throw error
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw CustomerError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            throw CustomerError.networkError
        }
    }
    
    // Add Address
    func addAddress(
        name: String,
        formattedAddress: String,
        latitude: Double,
        longitude: Double,
        street: String,
        neighborhood: String,
        district: String,
        city: String,
        province: String,
        postalCode: String,
        country: String
    ) async throws -> CustomerAddress {
        print("📍 CustomerService: addAddress başladı")
        print("📍 Adres adı: \(name)")
        
        // Customer ID kontrolü
        guard let customerId = authService.getCurrentCustomerId() else {
            print("❌ Customer ID bulunamadı")
            throw CustomerError.noAuthToken
        }
        
        print("👤 Customer ID: \(customerId)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/customers/\(customerId)/address") else {
            print("❌ URL oluşturulamadı")
            throw CustomerError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        // FormattedAddress'i parse et
        let parsedAddress = parseFormattedAddress(formattedAddress)
        
        // Request body oluştur - parse edilen bilgileri kullan
        let requestBody = AddAddressRequest(
            name: name,
            formattedAddress: formattedAddress,
            latitude: latitude,
            longitude: longitude,
            street: parsedAddress.street.isEmpty ? street : parsedAddress.street,
            neighborhood: parsedAddress.neighborhood.isEmpty ? neighborhood : parsedAddress.neighborhood,
            district: parsedAddress.district.isEmpty ? district : parsedAddress.district,
            city: parsedAddress.city.isEmpty ? city : parsedAddress.city,
            province: parsedAddress.province.isEmpty ? province : parsedAddress.province,
            postalCode: parsedAddress.postalCode.isEmpty ? postalCode : parsedAddress.postalCode,
            country: parsedAddress.country.isEmpty ? country : parsedAddress.country
        )
        
        do {
            // JSON body'yi encode et
            let jsonData = try JSONEncoder().encode(requestBody)
            print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
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
            
            guard (200...201).contains(httpResponse.statusCode) else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw CustomerError.serverError("Adres eklenemedi: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let customerResponse = try JSONDecoder().decode(CustomerWithAddressesResponse.self, from: data)
            
            print("✅ JSON başarıyla parse edildi")
            
            // Yeni eklenen adresi bul (en son eklenen)
            guard let newAddress = customerResponse.data.addresses.last else {
                print("❌ Yeni adres bulunamadı")
                throw CustomerError.invalidResponse
            }
            
            print("✅ Adres başarıyla eklendi: \(newAddress.id)")
            return newAddress
            
        } catch let error as CustomerError {
            print("❌ CustomerError: \(error.localizedDescription)")
            throw error
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw CustomerError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            throw CustomerError.networkError
        }
    }
    
    // Update Address
    func updateAddress(
        addressId: String,
        name: String,
        formattedAddress: String,
        latitude: Double,
        longitude: Double,
        street: String,
        neighborhood: String,
        district: String,
        city: String,
        province: String,
        postalCode: String,
        country: String
    ) async throws -> CustomerAddress {
        print("📍 CustomerService: updateAddress başladı")
        print("📍 Adres ID: \(addressId)")
        
        // Customer ID kontrolü
        guard let customerId = authService.getCurrentCustomerId() else {
            print("❌ Customer ID bulunamadı")
            throw CustomerError.noAuthToken
        }
        
        print("👤 Customer ID: \(customerId)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/customers/\(customerId)/address") else {
            print("❌ URL oluşturulamadı")
            throw CustomerError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        // FormattedAddress'i parse et
        let parsedAddress = parseFormattedAddress(formattedAddress)
        
        // Request body oluştur - parse edilen bilgileri kullan
        let requestBody = UpdateAddressRequest(
            id: addressId,
            name: name,
            formattedAddress: formattedAddress,
            latitude: latitude,
            longitude: longitude,
            street: parsedAddress.street.isEmpty ? street : parsedAddress.street,
            neighborhood: parsedAddress.neighborhood.isEmpty ? neighborhood : parsedAddress.neighborhood,
            district: parsedAddress.district.isEmpty ? district : parsedAddress.district,
            city: parsedAddress.city.isEmpty ? city : parsedAddress.city,
            province: parsedAddress.province.isEmpty ? province : parsedAddress.province,
            postalCode: parsedAddress.postalCode.isEmpty ? postalCode : parsedAddress.postalCode,
            country: parsedAddress.country.isEmpty ? country : parsedAddress.country
        )
        
        do {
            // JSON body'yi encode et
            let jsonData = try JSONEncoder().encode(requestBody)
            print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
            // Authenticated request at
            let (data, response) = try await authService.makeAuthenticatedRequest(
                to: url,
                method: "PUT",
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
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw CustomerError.serverError("Adres güncellenemedi: HTTP \(httpResponse.statusCode)")
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let customerResponse = try JSONDecoder().decode(CustomerWithAddressesResponse.self, from: data)
            
            print("✅ JSON başarıyla parse edildi")
            
            // Güncellenen adresi bul
            guard let updatedAddress = customerResponse.data.addresses.first(where: { $0.id == addressId }) else {
                print("❌ Güncellenen adres bulunamadı")
                throw CustomerError.invalidResponse
            }
            
            print("✅ Adres başarıyla güncellendi: \(updatedAddress.id)")
            return updatedAddress
            
        } catch let error as CustomerError {
            print("❌ CustomerError: \(error.localizedDescription)")
            throw error
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw CustomerError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            throw CustomerError.networkError
        }
    }
    
    // Delete Address
    func deleteAddress(addressId: String) async throws {
        print("📍 CustomerService: deleteAddress başladı")
        print("📍 Adres ID: \(addressId)")
        
        // Customer ID kontrolü
        guard let customerId = authService.getCurrentCustomerId() else {
            print("❌ Customer ID bulunamadı")
            throw CustomerError.noAuthToken
        }
        
        print("👤 Customer ID: \(customerId)")
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/customers/\(customerId)/address") else {
            print("❌ URL oluşturulamadı")
            throw CustomerError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        // Request body oluştur
        let requestBody = DeleteAddressRequest(id: addressId)
        
        do {
            // JSON body'yi encode et
            let jsonData = try JSONEncoder().encode(requestBody)
            print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            
            // Authenticated request at
            let (data, response) = try await authService.makeAuthenticatedRequest(
                to: url,
                method: "DELETE",
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
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw CustomerError.serverError("Adres silinemedi: HTTP \(httpResponse.statusCode)")
            }
            
            print("✅ Adres başarıyla silindi: \(addressId)")
            
        } catch let error as CustomerError {
            print("❌ CustomerError: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            throw CustomerError.networkError
        }
    }
}
