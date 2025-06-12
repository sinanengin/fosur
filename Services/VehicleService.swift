//
//  VehicleService.swift
//  fosur
//
//  Created by Sinan Engin Yıldız on 10.06.2025.
//

import Foundation
import UIKit

// MARK: - Vehicle API Models
struct VehicleBrand: Codable {
    let name: String
    let iconUrl: String
}

struct VehicleResponse: Codable {
    let data: VehicleData
}

struct VehicleData: Codable, Identifiable {
    let resourceUrn: String
    let name: String
    let model: String
    let plate: String
    let brand: VehicleBrand
    let id: String
    let images: [VehicleImage]
    let state: String
    let owner: String
    let domain: String
}

struct VehicleImage: Codable, Identifiable {
    let id: String
    let url: String
    let filename: String
    let contentType: String
    let size: Int
    let isCover: Bool
    let uploadedAt: String
}

struct CreateVehicleRequest: Codable {
    let model: String
    let plate: String
    let brand: VehicleBrand
    let name: String
    let owner: String
}

struct UpdateVehicleRequest: Codable {
    let model: String
    let plate: String
    let brand: VehicleBrand
    let name: String
}

// MARK: - Vehicle Errors
enum VehicleError: Error, LocalizedError {
    case noAuthToken
    case noCustomerId
    case networkError
    case invalidResponse
    case serverError(String)
    case vehicleNotFound
    case imageUploadFailed
    
    var errorDescription: String? {
        switch self {
        case .noAuthToken:
            return "Giriş yapmanız gerekiyor"
        case .noCustomerId:
            return "Müşteri bilgisi bulunamadı"
        case .networkError:
            return "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı"
        case .serverError(let message):
            return message
        case .vehicleNotFound:
            return "Araç bulunamadı"
        case .imageUploadFailed:
            return "Fotoğraf yüklenemedi"
        }
    }
}

// MARK: - VehicleService
class VehicleService: ObservableObject {
    static let shared = VehicleService()
    
    private let baseURL = "http://localhost:8080"
    private let authService = AuthService.shared
    
    @Published var vehicles: [VehicleData] = []
    @Published var isLoading = false
    
    // Cache durumu
    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300 // 5 dakika
    
    private init() {}
    
    // MARK: - Image Processing Helpers
    private func compressAndResizeImage(_ image: UIImage, maxSizeInMB: Double = 2.0) -> Data? {
        // Maksimum boyutları belirle (1080p ve altı)
        let maxWidth: CGFloat = 1080
        let maxHeight: CGFloat = 1080
        
        // Resmi yeniden boyutlandır
        let resizedImage = resizeImage(image, maxWidth: maxWidth, maxHeight: maxHeight)
        
        // Hedef dosya boyutu (bytes)
        let maxSizeInBytes = Int(maxSizeInMB * 1024 * 1024)
        
        // Sıkıştırma kalitesini başlat
        var compressionQuality: CGFloat = 0.8
        var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        
        // Dosya boyutu hedef boyuttan büyükse sıkıştırmaya devam et
        while let data = imageData, data.count > maxSizeInBytes && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        }
        
        if let finalData = imageData {
            let finalSizeInMB = Double(finalData.count) / (1024 * 1024)
            print("📸 Resim sıkıştırıldı: \(String(format: "%.2f", finalSizeInMB)) MB, kalite: \(String(format: "%.1f", compressionQuality))")
        }
        
        return imageData
    }
    
    private func resizeImage(_ image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let originalSize = image.size
        
        // Eğer resim zaten küçükse, olduğu gibi döndür
        if originalSize.width <= maxWidth && originalSize.height <= maxHeight {
            return image
        }
        
        // Aspect ratio'yu koru
        let widthRatio = maxWidth / originalSize.width
        let heightRatio = maxHeight / originalSize.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: originalSize.width * ratio,
            height: originalSize.height * ratio
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
    
    // MARK: - Create Vehicle
    func createVehicle(model: String, plate: String, brandName: String, vehicleName: String) async throws -> VehicleData {
        print("🚗 VehicleService: createVehicle başladı - Model: \(model), Brand: \(brandName)")
        
        await MainActor.run { self.isLoading = true }
        
        guard let customerId = authService.getCurrentCustomerId() else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.noCustomerId
        }
        
        guard let url = URL(string: "\(baseURL)/cars") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        let brand = VehicleBrand(name: brandName, iconUrl: "https://www.freeiconspng.com/img/28806")
        let request = CreateVehicleRequest(
            model: model,
            plate: plate,
            brand: brand,
            name: vehicleName,
            owner: "customer:\(customerId)"
        )
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Auth headers ekle
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            urlRequest.httpBody = try JSONEncoder().encode(request)
            
            print("🌐 Request URL: \(url)")
            print("📤 Request Body: \(String(data: urlRequest.httpBody!, encoding: .utf8) ?? "")")
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard httpResponse.statusCode == 201 else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.serverError("Araç oluşturulamadı: HTTP \(httpResponse.statusCode)")
            }
            
            let vehicleResponse = try JSONDecoder().decode(VehicleResponse.self, from: data)
            
            await MainActor.run {
                // Yeni aracı cache'e ekle
                self.vehicles.append(vehicleResponse.data)
                // Cache'i invalidate et ki bir sonraki getVehicles çağrısında API'den yeniden çeksin
                self.lastFetchTime = nil
                self.isLoading = false
            }
            
            print("✅ Araç başarıyla oluşturuldu: \(vehicleResponse.data.id)")
            print("🔄 Cache invalidate edildi - bir sonraki getVehicles API'den çekecek")
            return vehicleResponse.data
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ createVehicle Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Get Vehicles
    func getVehicles(forceRefresh: Bool = false) async throws -> [VehicleData] {
        print("🚗 VehicleService: getVehicles başladı (forceRefresh: \(forceRefresh))")
        
        // Cache kontrolü - force refresh yoksa ve cache geçerliyse
        if !forceRefresh, 
           !vehicles.isEmpty,
           let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheTimeout {
            print("✅ Cache'den \(vehicles.count) araç döndürülüyor")
            return vehicles
        }
        
        await MainActor.run { self.isLoading = true }
        
        guard let customerId = authService.getCurrentCustomerId() else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.noCustomerId
        }
        
        let queryParam = "owner==customer:\(customerId)"
        guard let url = URL(string: "\(baseURL)/cars?query=\(queryParam.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        do {
            let (data, response) = try await authService.makeAuthenticatedRequest(to: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard httpResponse.statusCode == 200 else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.serverError("Araçlar alınamadı: HTTP \(httpResponse.statusCode)")
            }
            
            let vehicleResponses = try JSONDecoder().decode([VehicleResponse].self, from: data)
            let vehicles = vehicleResponses.map { $0.data }
            
            await MainActor.run {
                self.vehicles = vehicles
                self.lastFetchTime = Date()
                self.isLoading = false
            }
            
            print("✅ \(vehicles.count) araç başarıyla alındı ve cache'lendi")
            return vehicles
            
        } catch {
            await MainActor.run { self.isLoading = false }
            
            // URLError cancelled hatasını farklı handle et
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ getVehicles: Request cancelled")
                throw VehicleError.networkError
            } else {
                print("❌ getVehicles Error: \(error)")
                throw error
            }
        }
    }
    
    // MARK: - Update Vehicle
    func updateVehicle(vehicleId: String, model: String, plate: String, brandName: String, vehicleName: String) async throws -> VehicleData {
        print("🚗 VehicleService: updateVehicle başladı - ID: \(vehicleId)")
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/cars/\(vehicleId)") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        let brand = VehicleBrand(name: brandName, iconUrl: "https://www.freeiconspng.com/img/28806")
        let request = UpdateVehicleRequest(model: model, plate: plate, brand: brand, name: vehicleName)
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "PUT"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            urlRequest.httpBody = try JSONEncoder().encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.serverError("Araç güncellenemedi: HTTP \(httpResponse.statusCode)")
            }
            
            let vehicleResponse = try JSONDecoder().decode(VehicleResponse.self, from: data)
            
            await MainActor.run {
                if let index = self.vehicles.firstIndex(where: { $0.id == vehicleId }) {
                    self.vehicles[index] = vehicleResponse.data
                }
                self.isLoading = false
            }
            
            print("✅ Araç başarıyla güncellendi")
            return vehicleResponse.data
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ updateVehicle Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Delete Vehicle
    func deleteVehicle(vehicleId: String) async throws {
        print("🚗 VehicleService: deleteVehicle başladı - ID: \(vehicleId)")
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/cars/\(vehicleId)") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 204 else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.serverError("Araç silinemedi: HTTP \(httpResponse.statusCode)")
            }
            
            await MainActor.run {
                self.vehicles.removeAll { $0.id == vehicleId }
                self.lastFetchTime = Date() // Cache'i güncelle
                self.isLoading = false
            }
            
            print("✅ Araç başarıyla silindi")
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ deleteVehicle Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Upload Multiple Images
    func uploadVehicleImages(vehicleId: String, images: [UIImage]) async throws -> [VehicleImage] {
        print("📸 VehicleService: uploadVehicleImages başladı - \(images.count) fotoğraf")
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/cars/\(vehicleId)/images/batch") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                if key != "Content-Type" { // Content-Type'ı aşağıda boundary ile set edeceğiz
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            let boundary = UUID().uuidString
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            for (index, image) in images.enumerated() {
                if let imageData = compressAndResizeImage(image) {
                    body.append("--\(boundary)\r\n".data(using: .utf8)!)
                    body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image_\(index).jpg\"\r\n".data(using: .utf8)!)
                    body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                    body.append(imageData)
                    body.append("\r\n".data(using: .utf8)!)
                }
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            urlRequest.httpBody = body
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                await MainActor.run { self.isLoading = false }
                
                // Hata detayını parse etmeye çalış
                if let errorData = String(data: data, encoding: .utf8) {
                    print("❌ API Hatası: \(errorData)")
                    throw VehicleError.serverError("Resim yükleme hatası: \(errorData)")
                } else {
                    throw VehicleError.imageUploadFailed
                }
            }
            
            let uploadedImages = try JSONDecoder().decode([VehicleImage].self, from: data)
            
            await MainActor.run { self.isLoading = false }
            
            print("✅ \(uploadedImages.count) fotoğraf başarıyla yüklendi")
            return uploadedImages
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ uploadVehicleImages Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Upload Single Image
    func uploadVehicleImage(vehicleId: String, image: UIImage) async throws -> VehicleImage {
        print("📸 VehicleService: uploadVehicleImage başladı")
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/cars/\(vehicleId)/images") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                if key != "Content-Type" { // Content-Type'ı aşağıda boundary ile set edeceğiz
                    urlRequest.setValue(value, forHTTPHeaderField: key)
                }
            }
            
            let boundary = UUID().uuidString
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            if let imageData = compressAndResizeImage(image) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            urlRequest.httpBody = body
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                await MainActor.run { self.isLoading = false }
                
                // Hata detayını parse etmeye çalış
                if let errorData = String(data: data, encoding: .utf8) {
                    print("❌ API Hatası: \(errorData)")
                    throw VehicleError.serverError("Resim yükleme hatası: \(errorData)")
                } else {
                    throw VehicleError.imageUploadFailed
                }
            }
            
            let uploadedImage = try JSONDecoder().decode(VehicleImage.self, from: data)
            
            await MainActor.run { self.isLoading = false }
            
            print("✅ Fotoğraf başarıyla yüklendi")
            return uploadedImage
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ uploadVehicleImage Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Delete Vehicle Image
    func deleteVehicleImage(vehicleId: String, imageId: String) async throws {
        print("🗑️ VehicleService: deleteVehicleImage başladı - ImageID: \(imageId)")
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/cars/\(vehicleId)/images/\(imageId)") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 204 else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.serverError("Fotoğraf silinemedi: HTTP \(httpResponse.statusCode)")
            }
            
            await MainActor.run { self.isLoading = false }
            
            print("✅ Fotoğraf başarıyla silindi")
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ deleteVehicleImage Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Delete All Vehicle Images
    func deleteAllVehicleImages(vehicleId: String) async throws {
        print("🗑️ VehicleService: deleteAllVehicleImages başladı")
        
        await MainActor.run { self.isLoading = true }
        
        guard let url = URL(string: "\(baseURL)/cars/\(vehicleId)/images") else {
            await MainActor.run { self.isLoading = false }
            throw VehicleError.networkError
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
            
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 204 else {
                await MainActor.run { self.isLoading = false }
                throw VehicleError.serverError("Tüm fotoğraflar silinemedi: HTTP \(httpResponse.statusCode)")
            }
            
            await MainActor.run { self.isLoading = false }
            
            print("✅ Tüm fotoğraflar başarıyla silindi")
            
        } catch {
            await MainActor.run { self.isLoading = false }
            print("❌ deleteAllVehicleImages Error: \(error)")
            throw error
        }
    }
    
    // MARK: - Get Vehicle Details by Car ID
    func getVehicleDetails(car: String) async throws -> Vehicle {
        print("🚗 VehicleService: getVehicleDetails başladı - Car ID: \(car)")
        
        // Önce cache'den kontrol et
        if let cachedVehicle = vehicles.first(where: { "car:\($0.id)" == car }) {
            print("✅ Cache'den araç bulundu: \(cachedVehicle.brand.name) \(cachedVehicle.model)")
            return convertVehicleDataToVehicle(cachedVehicle)
        }
        
        // Cache'de yoksa API'den çek
        let carId = car.replacingOccurrences(of: "car:", with: "")
        guard let url = URL(string: "\(baseURL)/cars/\(carId)") else {
            throw VehicleError.networkError
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // Auth headers ekle
            let headers = authService.getAuthHeaders()
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VehicleError.invalidResponse
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 {
                let vehicleResponse = try JSONDecoder().decode(VehicleResponse.self, from: data)
                let vehicle = convertVehicleDataToVehicle(vehicleResponse.data)
                
                print("✅ Araç detayları alındı: \(vehicle.brand) \(vehicle.model)")
                return vehicle
            } else {
                throw VehicleError.vehicleNotFound
            }
        } catch {
            print("❌ getVehicleDetails Error: \(error)")
            throw error
        }
    }
    
    // VehicleData'yı Vehicle model'ine çevir
    private func convertVehicleDataToVehicle(_ vehicleData: VehicleData) -> Vehicle {
        return Vehicle(
            id: UUID(),
            apiId: vehicleData.id,
            brand: vehicleData.brand.name,
            model: vehicleData.model,
            plate: vehicleData.plate,
            type: .automobile,
            images: vehicleData.images,
            userId: UUID(),
            lastServices: [],
            name: vehicleData.name
        )
    }
}
