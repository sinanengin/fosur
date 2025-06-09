import SwiftUI

enum PhoneLoginStep {
    case phone, code, name, mail
}

struct PhoneLoginView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService.shared
    @State private var step: PhoneLoginStep = .phone
    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var mail: String = ""
    
    // API ve Loading state'leri
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    // Animasyon ve görsel state'ler
    @State private var offset: CGFloat = 0
    @State private var isAnimating: Bool = false
    
    // Doğrulama kuralları
    var isPhoneValid: Bool {
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phoneNumber)
    }
    
    var isCodeValid: Bool {
        code.count == 6 && code.allSatisfy { $0.isNumber }
    }
    
    var isNameValid: Bool {
        name.count > 1 && surname.count > 1
    }
    
    var isMailValid: Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: mail)
    }
    
    // Focus state'leri
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isCodeFieldFocused: Bool
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isSurnameFieldFocused: Bool
    @FocusState private var isMailFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Arka plan gradyeni
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("BackgroundColor"),
                            Color("BackgroundColor").opacity(0.95)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header
                        headerView
                        
                        // İlerleme çubuğu
                        progressBar
                        
                        // İçerik
                        ZStack {
                            phoneStepView
                                .opacity(step == .phone ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: step)
                            
                            codeStepView
                                .opacity(step == .code ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: step)
                            
                            nameStepView
                                .opacity(step == .name ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: step)
                            
                            mailStepView
                                .opacity(step == .mail ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: step)
                        }
                        .animation(.easeInOut(duration: 0.4), value: step)
                        
                        Spacer()
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) // Klavye için güvenli alan ayarı
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            setupInitialFocus()
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            // Geri Butonu
            Button(action: {
                if step == .phone {
                    // İlk adımda geri tuşu ile çık ve misafir olarak kal
                    dismiss()
                } else {
                    // Diğer adımlarda önceki adıma git
                    withAnimation(.easeInOut(duration: 0.3)) {
                        goToPreviousStep()
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            Text(stepTitle)
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Sağ tarafta boş alan (dengelemek için)
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - İlerleme Çubuğu
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach([PhoneLoginStep.phone, .code, .name, .mail], id: \.self) { currentStep in
                Rectangle()
                    .fill(getCurrentStepIndex() >= getStepIndex(currentStep) ? Color.logo : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                    .animation(.easeInOut(duration: 0.3), value: step)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Telefon Adımı
    private var phoneStepView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Telefon Numaranızı Girin")
                    .font(CustomFont.bold(size: 28))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("Size SMS ile doğrulama kodu göndereceğiz")
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 24) {
                HStack(spacing: 0) {
                    Text("+90")
                        .font(CustomFont.bold(size: 20))
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16, corners: [.topLeft, .bottomLeft])
                    
                    TextField("5XX XXX XX XX", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .font(CustomFont.regular(size: 20))
                        .padding(.vertical, 18)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(16, corners: [.topRight, .bottomRight])
                        .onChange(of: phoneNumber) { oldValue, newValue in
                            phoneNumber = String(newValue.prefix(10).filter { $0.isNumber })
                        }
                        .focused($isPhoneFieldFocused)
                }
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                Button(action: {
                    sendVerificationCode()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Doğrulama Kodu Gönder")
                                .font(CustomFont.bold(size: 18))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background((isPhoneValid && !isLoading) ? Color.logo : Color.gray.opacity(0.4))
                    .cornerRadius(16)
                    .shadow(color: (isPhoneValid && !isLoading) ? Color.logo.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!isPhoneValid || isLoading)
                .scaleEffect((isPhoneValid && !isLoading) ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: isPhoneValid)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Kod Doğrulama Adımı
    private var codeStepView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Doğrulama Kodu")
                    .font(CustomFont.bold(size: 28))
                    .foregroundColor(.primary)
                
                Text("+90 \(phoneNumber) numarasına gönderilen 6 haneli kodu girin")
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
            VStack(spacing: 24) {
                // Kod giriş kutuları
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .frame(width: 48, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(code.count > index ? Color.logo : Color.gray.opacity(0.3), lineWidth: 2)
                                )
                            
                            Text(code.count > index ? String(code[code.index(code.startIndex, offsetBy: index)]) : "")
                                .font(CustomFont.bold(size: 24))
                                .foregroundColor(.primary)
                        }
                        .scaleEffect(code.count == index ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: code.count)
                    }
                }
                .onTapGesture {
                    isCodeFieldFocused = true
                }
                
                // Gizli TextField
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .opacity(0.01)
                    .frame(width: 0, height: 0)
                    .onChange(of: code) { oldValue, newValue in
                        code = String(newValue.prefix(6).filter { $0.isNumber })
                    }
                    .focused($isCodeFieldFocused)
                
                Button(action: {
                    verifyPhoneCode()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Devam Et")
                                .font(CustomFont.bold(size: 18))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background((isCodeValid && !isLoading) ? Color.logo : Color.gray.opacity(0.4))
                    .cornerRadius(16)
                    .shadow(color: (isCodeValid && !isLoading) ? Color.logo.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!isCodeValid || isLoading)
                .scaleEffect((isCodeValid && !isLoading) ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: isCodeValid)
                
                Button(action: {
                    resendVerificationCode()
                }) {
                    Text("Kodu yeniden gönder")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(Color.logo)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - İsim Adımı
    private var nameStepView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Adınızı Öğrenelim")
                    .font(CustomFont.bold(size: 28))
                    .foregroundColor(.primary)
                
                Text("Sizi nasıl çağırmamızı istiyorsunuz?")
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    TextField("Adınız", text: $name)
                        .font(CustomFont.regular(size: 18))
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .focused($isNameFieldFocused)
                    
                    TextField("Soyadınız", text: $surname)
                        .font(CustomFont.regular(size: 18))
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .focused($isSurnameFieldFocused)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        step = .mail
                        setupFocusForStep(.mail)
                    }
                }) {
                    HStack {
                        Text("Devam Et")
                            .font(CustomFont.bold(size: 18))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(isNameValid ? Color.logo : Color.gray.opacity(0.4))
                    .cornerRadius(16)
                    .shadow(color: isNameValid ? Color.logo.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!isNameValid)
                .scaleEffect(isNameValid ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: isNameValid)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - E-posta Adımı
    private var mailStepView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Son Adım!")
                    .font(CustomFont.bold(size: 28))
                    .foregroundColor(.primary)
                
                Text("E-posta adresinizi girin ve hesabınızı oluşturalım")
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            
            VStack(spacing: 24) {
                TextField("E-posta adresiniz", text: $mail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .font(CustomFont.regular(size: 18))
                    .padding(.vertical, 18)
                    .padding(.horizontal, 20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .focused($isMailFieldFocused)
                
                Button(action: {
                    createUserAccount()
                }) {
                    HStack {
                        Text("Hesabımı Oluştur")
                            .font(CustomFont.bold(size: 18))
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(isMailValid ? Color.logo : Color.gray.opacity(0.4))
                    .cornerRadius(16)
                    .shadow(color: isMailValid ? Color.logo.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!isMailValid)
                .scaleEffect(isMailValid ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: isMailValid)
                
                VStack(spacing: 8) {
                    Text("Hesap oluşturarak")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("Kullanım Şartları") {
                            // Terms of service
                        }
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(Color.logo)
                        
                        Text("ve")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                        
                        Button("Gizlilik Politikası") {
                            // Privacy policy
                        }
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(Color.logo)
                    }
                    
                    Text("kabul etmiş olursunuz")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - API Methods
    private func sendVerificationCode() {
        guard !isLoading else { return }
        
        print("📱 PhoneLoginView: SMS gönderimi başlıyor")
        print("📱 Girilen telefon: \(phoneNumber)")
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                let formattedPhone = "+90" + phoneNumber
                print("📱 Gönderilecek telefon: \(formattedPhone)")
                
                try await authService.sendPhoneVerification(formattedPhone)
                
                print("✅ SMS başarıyla gönderildi, kod adımına geçiliyor")
                
                await MainActor.run {
                    isLoading = false
                    withAnimation(.easeInOut(duration: 0.4)) {
                        step = .code
                        setupFocusForStep(.code)
                    }
                }
            } catch {
                print("❌ SMS gönderim hatası: \(error)")
                print("❌ Error type: \(type(of: error))")
                print("❌ Localized description: \(error.localizedDescription)")
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func verifyPhoneCode() {
        guard !isLoading else { return }
        
        print("🔢 PhoneLoginView: Kod doğrulama başlıyor")
        print("📱 Telefon: \(phoneNumber)")
        print("🔢 Girilen kod: \(code)")
        
        isLoading = true
        errorMessage = ""
        showError = false
        
        Task {
            do {
                let formattedPhone = "+90" + phoneNumber
                print("📱 Doğrulanacak telefon: \(formattedPhone)")
                
                let userDetails = try await authService.verifyPhone(formattedPhone, code: code)
                
                print("✅ Kod doğrulandı, kullanıcı giriş yapıyor")
                print("👤 User ID: \(userDetails.id)")
                print("📧 Email: \(userDetails.email ?? "none")")
                print("👤 Name: \(userDetails.name ?? "none")")
                
                await MainActor.run {
                    isLoading = false
                    // Token ve user details başarıyla alındı ve AuthService'e kaydedildi
                    // Artık uygulamanın her yerinden erişilebilir durumda
                    
                    print("✅ Token ve user details kaydedildi, kayıt aşamasına geçiliyor")
                    
                    // Sonraki adım (name) adımına geç
                    withAnimation(.easeInOut(duration: 0.4)) {
                        step = .name
                        setupFocusForStep(.name)
                    }
                }
            } catch {
                print("❌ Kod doğrulama hatası: \(error)")
                print("❌ Error type: \(type(of: error))")
                print("❌ Localized description: \(error.localizedDescription)")
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func resendVerificationCode() {
        print("🔄 PhoneLoginView: Kod yeniden gönderiliyor")
        sendVerificationCode()
    }
    
    // MARK: - Helper Methods
    private var stepTitle: String {
        switch step {
        case .phone: return "Telefon"
        case .code: return "Doğrulama"
        case .name: return "Bilgiler"
        case .mail: return "E-posta"
        }
    }
    
    private func getCurrentStepIndex() -> Int {
        getStepIndex(step)
    }
    
    private func getStepIndex(_ step: PhoneLoginStep) -> Int {
        switch step {
        case .phone: return 0
        case .code: return 1
        case .name: return 2
        case .mail: return 3
        }
    }
    
    private func goToPreviousStep() {
        switch step {
        case .code: step = .phone
        case .name: step = .code
        case .mail: step = .name
        case .phone: break
        }
        setupFocusForStep(step)
    }
    
    private func setupInitialFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPhoneFieldFocused = true
        }
    }
    
    private func setupFocusForStep(_ step: PhoneLoginStep) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch step {
            case .phone: isPhoneFieldFocused = true
            case .code: isCodeFieldFocused = true
            case .name: isNameFieldFocused = true
            case .mail: isMailFieldFocused = true
            }
        }
    }
    
    private func createUserAccount() {
        // MongoDB entegrasyonu için hazırlık - şimdilik lokal kayıt
        let newUser = User(
            id: UUID(),
            name: name,
            surname: surname,
            email: mail,
            phoneNumber: "+90" + phoneNumber,
            profileImage: nil,
            vehicles: []
        )
        
        // AppState'i güncelle ve misafir kullanıcıyı gerçek kullanıcı ile değiştir
        appState.currentUser = newUser
        appState.isUserLoggedIn = true
        appState.tabSelection = .callUs
        
        // Başarı animasyonu ile çıkış
        withAnimation(.easeInOut(duration: 0.5)) {
            dismiss()
        }
    }
} 