import Foundation

// MARK: - Auth Request Models
struct PhoneAuthRequest: Codable {
    let phone: String
}

struct VerifyPhoneRequest: Codable {
    let phoneNumber: String
    let code: String
}

// MARK: - Auth Response Models
struct VerifyPhoneResponse: Codable {
    let userDetails: UserDetails
    let token: String
}

struct UserDetails: Codable {
    let id: String
    let provider: String
    let emailVerified: Bool
    let lastSignInAt: String
    let resourceUrn: String
    let avatarUrl: String?
    let username: String?
    let email: String?
    let phoneNumber: String
    let name: String?
    let createdBy: String?
    let createdDate: String
    let lastModifiedBy: String?
    let lastModifiedDate: String
    let state: String
    let claims: UserClaims
    let domain: String
}

struct UserClaims: Codable {
    let claims: [String: [String]]  // Dinamik claims objesi
    let allPermissions: [String]
}

// MARK: - Auth Errors
enum AuthError: Error, LocalizedError {
    case invalidPhoneNumber
    case invalidCode
    case networkError
    case invalidResponse
    case serverError(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return "Geçersiz telefon numarası"
        case .invalidCode:
            return "Geçersiz doğrulama kodu"
        case .networkError:
            return "Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin."
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt alındı"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Yetkilendirme hatası. Lütfen tekrar giriş yapın."
        }
    }
}

// MARK: - AuthService
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let baseURL = "http://localhost:8080"
    private let session = URLSession.shared
    
    // Token ve user bilgileri
    @Published var isAuthenticated = false
    @Published var currentUser: UserDetails?
    
    private var authToken: String? {
        get {
            UserDefaults.standard.string(forKey: "auth_token")
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: "auth_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "auth_token")
            }
            DispatchQueue.main.async {
                self.isAuthenticated = newValue != nil
            }
        }
    }
    
    private init() {
        // Uygulama açıldığında token kontrolü
        if let _ = authToken {
            isAuthenticated = true
            // TODO: Token geçerliliğini kontrol et
        }
    }
    
    // MARK: - Phone Authentication (Step 1)
    func sendPhoneVerification(_ phoneNumber: String) async throws {
        print("🔐 AuthService: sendPhoneVerification başladı")
        print("📱 Telefon numarası: \(phoneNumber)")
        
        // Telefon numarası validasyonu
        let formattedPhone = formatPhoneNumber(phoneNumber)
        print("📱 Formatlanmış telefon: \(formattedPhone)")
        
        guard isValidPhoneNumber(formattedPhone) else {
            print("❌ Geçersiz telefon numarası")
            throw AuthError.invalidPhoneNumber
        }
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/auth/phone") else {
            print("❌ URL oluşturulamadı: \(baseURL)/auth/phone")
            throw AuthError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        // Request body oluştur
        let requestBody = PhoneAuthRequest(phone: formattedPhone)
        
        // URLRequest oluştur
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // JSON body'yi encode et
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            print("📤 HTTP Method: \(request.httpMethod ?? "nil")")
            print("📤 Headers: \(request.allHTTPHeaderFields ?? [:])")
            
            print("⏳ İstek gönderiliyor...")
            
            // İsteği gönder
            let (data, response) = try await session.data(for: request)
            
            print("📥 Response alındı")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "empty")")
            
            // HTTP status code kontrol et
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ HTTPURLResponse cast edilemedi")
                throw AuthError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📊 Response Headers: \(httpResponse.allHeaderFields)")
            
            // 204 No Content bekliyoruz
            guard httpResponse.statusCode == 204 else {
                print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                throw AuthError.serverError("SMS gönderimi başarısız: HTTP \(httpResponse.statusCode)")
            }
            
            print("✅ SMS başarıyla gönderildi!")
            
        } catch let error as AuthError {
            print("❌ AuthError: \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ Network Error: \(error)")
            print("❌ Error Type: \(type(of: error))")
            throw AuthError.networkError
        }
    }
    
    // MARK: - Phone Verification (Step 2)
    func verifyPhone(_ phoneNumber: String, code: String) async throws -> UserDetails {
        print("🔐 AuthService: verifyPhone başladı")
        print("📱 Telefon: \(phoneNumber)")
        print("🔢 Kod: \(code)")
        
        // Validasyonlar
        let formattedPhone = formatPhoneNumber(phoneNumber)
        print("📱 Formatlanmış telefon: \(formattedPhone)")
        
        guard isValidPhoneNumber(formattedPhone) else {
            print("❌ Geçersiz telefon numarası")
            throw AuthError.invalidPhoneNumber
        }
        
        guard !code.isEmpty, code.count == 6 else {
            print("❌ Geçersiz kod: uzunluk \(code.count)")
            throw AuthError.invalidCode
        }
        
        // URL oluştur
        guard let url = URL(string: "\(baseURL)/auth/verify-phone") else {
            print("❌ URL oluşturulamadı: \(baseURL)/auth/verify-phone")
            throw AuthError.networkError
        }
        
        print("🌐 Request URL: \(url)")
        
        // Request body oluştur
        let requestBody = VerifyPhoneRequest(phoneNumber: formattedPhone, code: code)
        
        // URLRequest oluştur
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // JSON body'yi encode et
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
            
            print("📤 Request Body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
            print("📤 HTTP Method: \(request.httpMethod ?? "nil")")
            print("📤 Headers: \(request.allHTTPHeaderFields ?? [:])")
            
            print("⏳ Doğrulama isteği gönderiliyor...")
            
            // İsteği gönder
            let (data, response) = try await session.data(for: request)
            
            print("📥 Response alındı")
            print("📥 Response Data: \(String(data: data, encoding: .utf8) ?? "empty")")
            
            // HTTP status code kontrol et
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ HTTPURLResponse cast edilemedi")
                throw AuthError.networkError
            }
            
            print("📊 HTTP Status Code: \(httpResponse.statusCode)")
            print("📊 Response Headers: \(httpResponse.allHeaderFields)")
            
            // 200 OK bekliyoruz
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    print("❌ Unauthorized: Kod hatalı olabilir")
                    throw AuthError.serverError("Doğrulama kodu hatalı")
                } else {
                    print("❌ Beklenmeyen status code: \(httpResponse.statusCode)")
                    throw AuthError.serverError("Doğrulama başarısız: HTTP \(httpResponse.statusCode)")
                }
            }
            
            // Response'u parse et
            print("⚙️ JSON parsing başlıyor...")
            let verifyResponse = try JSONDecoder().decode(VerifyPhoneResponse.self, from: data)
            print("✅ JSON başarıyla parse edildi")
            print("🪙 Token: \(verifyResponse.token.prefix(20))...")
            print("👤 User ID: \(verifyResponse.userDetails.id)")
            
            // Token ve user bilgilerini main thread'de sakla
            await MainActor.run {
                authToken = verifyResponse.token
                currentUser = verifyResponse.userDetails
                isAuthenticated = true
            }
            
            // Token ve user details'i local storage'a kaydet
            saveTokenToStorage(verifyResponse.token)
            saveUserDetailsToStorage(verifyResponse.userDetails)
            
            print("✅ Token ve user bilgileri kaydedildi")
            
            return verifyResponse.userDetails
            
        } catch let error as AuthError {
            print("❌ AuthError: \(error.localizedDescription)")
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
            throw AuthError.invalidResponse
        } catch {
            print("❌ Network Error: \(error)")
            print("❌ Error Type: \(type(of: error))")
            throw AuthError.networkError
        }
    }
    
    // MARK: - Local Storage Management
    func saveTokenToStorage(_ token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        print("💾 Auth token local storage'a kaydedildi")
    }
    
    func saveUserDetailsToStorage(_ userDetails: UserDetails) {
        do {
            let data = try JSONEncoder().encode(userDetails)
            UserDefaults.standard.set(data, forKey: "user_details")
            print("💾 User details local storage'a kaydedildi")
        } catch {
            print("❌ User details kaydedilirken hata: \(error)")
        }
    }
    
    func getTokenFromStorage() -> String? {
        return UserDefaults.standard.string(forKey: "auth_token")
    }
    
    func getUserDetailsFromStorage() -> UserDetails? {
        guard let data = UserDefaults.standard.data(forKey: "user_details") else {
            return nil
        }
        
        do {
            let userDetails = try JSONDecoder().decode(UserDetails.self, from: data)
            return userDetails
        } catch {
            print("❌ User details okurken hata: \(error)")
            return nil
        }
    }
    
    func clearStoredAuth() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "user_details")
        print("🗑️ Local storage'daki auth bilgileri temizlendi")
    }
    
    // Uygulama başlangıcında kullanılacak
    func loadStoredAuth() -> Bool {
        guard let token = getTokenFromStorage(),
              let userDetails = getUserDetailsFromStorage() else {
            print("❌ Local storage'da auth bilgileri bulunamadı")
            return false
        }
        
        // Memory'ye yükle
        authToken = token
        currentUser = userDetails
        isAuthenticated = true
        
        print("✅ Local storage'dan auth bilgileri yüklendi")
        print("👤 User ID: \(userDetails.id)")
        print("📱 Phone: \(userDetails.phoneNumber)")
        
        return true
    }
    
    // Customer bilgileriyle birlikte otomatik giriş
    func autoLoginWithStoredAuth() async throws -> Bool {
        guard loadStoredAuth() else {
            return false
        }
        
        guard let userDetails = currentUser else {
            return false
        }
        
        // Customer bilgilerini çek
        do {
            let customers = try await CustomerService.shared.searchCustomers(userId: userDetails.id)
            if let customer = customers.first {
                // Customer ID'yi kaydet
                saveCustomerId(customer.id)
                print("✅ Auto-login başarılı - Customer ID: \(customer.id)")
                return true
            } else {
                print("❌ Customer bulunamadı, auto-login başarısız")
                return false
            }
        } catch {
            print("❌ Auto-login sırasında hata: \(error)")
            return false
        }
    }
    
    // MARK: - Customer Management
    func saveCustomerId(_ customerId: String) {
        UserDefaults.standard.set(customerId, forKey: "customer_id")
        print("💾 Customer ID kaydedildi: \(customerId)")
    }
    
    func getCurrentCustomerId() -> String? {
        return UserDefaults.standard.string(forKey: "customer_id")
    }
    
    // MARK: - Token Management
    func logout() {
        authToken = nil
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "customer_id")
        clearStoredAuth()
        print("🚪 Kullanıcı çıkış yaptı, tüm veriler temizlendi")
    }
    
    func getAuthHeaders() -> [String: String] {
        guard let token = authToken else {
            return [:]
        }
        
        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }
    
    // MARK: - Authenticated Request Helper
    func makeAuthenticatedRequest(to url: URL, method: String = "GET", body: Data? = nil) async throws -> (Data, URLResponse) {
        guard authToken != nil else {
            throw AuthError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Auth headers ekle
        let headers = getAuthHeaders()
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return try await session.data(for: request)
    }
    
    // MARK: - Helper Methods
    private func isValidPhoneNumber(_ phone: String) -> Bool {
        // Türkiye telefon numarası validasyonu
        let phoneRegex = "^\\+90[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    // Telefon numarasını format'la (+90 prefix ekle)
    func formatPhoneNumber(_ phone: String) -> String {
        let cleanPhone = phone.replacingOccurrences(of: " ", with: "")
                              .replacingOccurrences(of: "(", with: "")
                              .replacingOccurrences(of: ")", with: "")
                              .replacingOccurrences(of: "-", with: "")
        
        if cleanPhone.hasPrefix("0") {
            return "+90" + String(cleanPhone.dropFirst())
        } else if cleanPhone.hasPrefix("90") {
            return "+" + cleanPhone
        } else if cleanPhone.hasPrefix("+90") {
            return cleanPhone
        } else {
            return "+90" + cleanPhone
        }
    }
}
