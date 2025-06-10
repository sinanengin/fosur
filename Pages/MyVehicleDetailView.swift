import SwiftUI

struct MyVehicleDetailView: View {
    let vehicle: Vehicle
    @EnvironmentObject var appState: AppState
    @StateObject private var vehicleService = VehicleService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingActionSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingUpdateForm = false
    @State private var showingUpdateConfirmation = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    // Photo management states
    @State private var vehicleImages: [VehicleImage] = []
    @State private var showingPhotoEditView = false
    
    // Update form states
    @State private var selectedBrandIndex: Int?
    @State private var selectedModel: String = ""
    @State private var vehicleName: String = ""
    @State private var plateNumber: String = ""
    @State private var plateValidationMessage: String = ""
    @State private var brandSearchText: String = ""
    @State private var modelSearchText: String = ""
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                vehicleImageSection
                vehicleInfoCard
                photoManagementSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color("BackgroundColor"))
        .navigationBarHidden(true)
        .task {
            await loadVehicleDetails()
        }
        .onAppear {
            print("🚗 MyVehicleDetailView açıldı")
            print("📸 showingPhotoEditView initial değeri: \(showingPhotoEditView)")
        }

        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Aracı Sil", isPresented: $showingDeleteConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task { await deleteVehicle() }
            }
        } message: {
            Text("Bu aracı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
        .confirmationDialog("Araç İşlemleri", isPresented: $showingActionSheet) {
            Button("Aracı Güncelle") { showingUpdateForm = true }
            Button("Görselleri Düzenle") { 
                print("🔄 Görselleri Düzenle butonuna basıldı!")
                showingPhotoEditView = true 
            }
            Button("Aracı Sil", role: .destructive) { showingDeleteConfirmation = true }
            Button("İptal", role: .cancel) { }
        }
        .sheet(isPresented: $showingUpdateForm) {
            updateFormView
        }
        .sheet(isPresented: $showingPhotoEditView) {
            VehiclePhotoEditView(
                vehicle: vehicle,
                vehicleImages: $vehicleImages
            )
        }

    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            
            Spacer()
            
            Button(action: { showingActionSheet = true }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: - Vehicle Image Section
    private var vehicleImageSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 200)
                
                // temp_car görseli - büyütülmüş
                Image("temp_car")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
            }
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
        }
    }
    
    // MARK: - Vehicle Info Card
    private var vehicleInfoCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Image(systemName: "car.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.logo)
                    .background(Circle().fill(Color.logo.opacity(0.1)))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(vehicle.brand) \(vehicle.model)")
                        .font(CustomFont.bold(size: 22))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "number.square")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text(vehicle.plate)
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
    
    // MARK: - Photo Management Section
    private var photoManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Araç Fotoğrafları")
                .font(CustomFont.bold(size: 20))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isLoading {
                photoLoadingView
            } else if vehicleImages.isEmpty {
                emptyPhotosView
            } else {
                photoGridView
            }
        }
    }
    
    private var photoLoadingView: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<4, id: \.self) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(12)
            }
        }
    }
    
    private var emptyPhotosView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("Henüz fotoğraf eklenmemiş")
                .font(CustomFont.regular(size: 16))
                .foregroundColor(.secondary)
            
            Text("3 nokta menüsünden 'Görselleri Düzenle' seçin")
                .font(CustomFont.medium(size: 16))
                .foregroundColor(.logo)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.logo.opacity(0.1))
                .cornerRadius(12)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
        )
    }
    
    private var photoGridView: some View {
        VStack(spacing: 16) {
            // Interior Photos
            if !interiorPhotos.isEmpty {
                photoSectionView(title: "İç Mekan", photos: interiorPhotos)
            }
            
            // Exterior Photos
            if !exteriorPhotos.isEmpty {
                photoSectionView(title: "Dış Mekan", photos: exteriorPhotos)
            }
            
            // Eğer hiç kategorize edilememiş fotoğraflar varsa veya tüm fotoğrafları göstermek istenirse
            if interiorPhotos.isEmpty && exteriorPhotos.isEmpty && !vehicleImages.isEmpty {
                photoSectionView(title: "Tüm Fotoğraflar", photos: vehicleImages)
            }
            
            // Debug: Toplam fotoğraf sayısını göster
            if !vehicleImages.isEmpty {
                Text("Toplam \(vehicleImages.count) fotoğraf yüklendi")
                    .font(CustomFont.regular(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
    }
    
    private func photoSectionView(title: String, photos: [VehicleImage]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(CustomFont.bold(size: 16))
                    .foregroundColor(.primary)

                Spacer()

                // Debug: Kategori bilgisi
                Text("(\(photos.count))")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    photoCardView(photo: photo)
                }
            }
        }
    }
    
    private func photoCardView(photo: VehicleImage) -> some View {
        AsyncImage(url: URL(string: photo.url)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .logo))
                )
        }
        .frame(height: 120)
        .clipped()
        .cornerRadius(12)
    }
    
    // MARK: - Update Form View
    private var updateFormView: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                updateFormHeaderSection
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Title Section
                        VStack(spacing: 16) {
                            Image(systemName: "car.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.logo)
                            
                            VStack(spacing: 8) {
                                Text("Araç Bilgilerini Güncelle")
                                    .font(CustomFont.bold(size: 24))
                                    .foregroundColor(.primary)
                                
                                Text("Araç bilgilerinizi güncelleyebilirsiniz")
                                    .font(CustomFont.regular(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Brand Selection
                        brandSelectionSection
                        
                        // Model Selection
                        modelSelectionSection
                        
                        // Plate Section
                        plateSection
                        
                        // Vehicle Name Section
                        vehicleNameSection
                    }
                    .padding(.horizontal, 20)
                }
                
                // Bottom Button
                updateButtonSection
            }
            .background(Color("BackgroundColor"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                initializeFormData()
            }
            .confirmationDialog("Güncellemek istiyor musunuz?", isPresented: $showingUpdateConfirmation) {
                Button("Evet") {
                    Task { await updateVehicle() }
                }
                Button("Hayır", role: .cancel) { }
            } message: {
                Text("Değişiklikleri kaydetmek istiyor musunuz?")
            }
        }
    }
    
    private var updateFormHeaderSection: some View {
        HStack {
            Button(action: { showingUpdateForm = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.gray.opacity(0.1)))
            }
            
            Spacer()
            
            Text("Araç Düzenle")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Empty space for symmetry
            Rectangle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Brand Selection Section
    private var brandSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Marka Seçimi")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            // Search bar
            searchBarView(text: $brandSearchText, placeholder: "Marka ara...")
            
            // Brand list
            let filteredBrands = brandSearchText.isEmpty ? vehicleBrands : vehicleBrands.filter { $0.name.localizedCaseInsensitiveContains(brandSearchText) }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(filteredBrands.enumerated()), id: \.element.id) { index, brand in
                        let originalIndex = vehicleBrands.firstIndex(where: { $0.name == brand.name }) ?? 0
                        brandCardView(brand: brand, isSelected: selectedBrandIndex == originalIndex) {
                            selectedBrandIndex = originalIndex
                            selectedModel = "" // Reset model when brand changes
                            modelSearchText = ""
                        }
                    }
                }
            }
            .frame(maxHeight: 150) // Kaydırılabilir alan
        }
    }
    
    // MARK: - Model Selection Section
    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Model Seçimi")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            // Search bar
            searchBarView(text: $modelSearchText, placeholder: "Model ara...")
            
            // Model list
            if let brandIndex = selectedBrandIndex {
                let models = vehicleBrands[brandIndex].models
                let filteredModels = modelSearchText.isEmpty ? models : models.filter { $0.localizedCaseInsensitiveContains(modelSearchText) }
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredModels, id: \.self) { model in
                            modelCardView(model: model, isSelected: selectedModel == model) {
                                selectedModel = model
                            }
                        }
                    }
                }
                .frame(maxHeight: 150) // Kaydırılabilir alan
            }
        }
    }
    
    private var plateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Plaka Bilgisi")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                TextField("34 ABC 123", text: $plateNumber)
                    .font(CustomFont.medium(size: 18))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(plateValidationMessage.isEmpty ? 
                                Color.logo.opacity(plateNumber.isEmpty ? 0 : 1) : 
                                Color.red.opacity(0.8), lineWidth: 2)
                    )
                    .textInputAutocapitalization(.characters)
                    .onChange(of: plateNumber) { newValue in
                        let formatted = formatPlate(newValue)
                        if formatted != newValue {
                            plateNumber = formatted
                        }
                        validateTurkishPlate(plateNumber)
                    }
                
                VStack(spacing: 8) {
                    if !plateValidationMessage.isEmpty {
                        Text(plateValidationMessage)
                            .font(CustomFont.regular(size: 12))
                            .foregroundColor(.red)
                    }
                    
                    Text("Örnekler: 34 A 1234, 06 AB 123, 35 ABC 12")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    // MARK: - Vehicle Name Section
    private var vehicleNameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Araç İsmi (Opsiyonel)")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            TextField("Araç ismi girin", text: $vehicleName)
                .font(CustomFont.medium(size: 16))
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.logo.opacity(vehicleName.isEmpty ? 0 : 0.5), lineWidth: 2)
                )
                .onAppear {
                    vehicleName = vehicle.name ?? "" // Mevcut isim varsa göster
                }
        }
    }
    
    // MARK: - Update Button Section
    private var updateButtonSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            Button("Güncelle") {
                // Önce değişiklik olup olmadığını kontrol et
                if hasFormChanges() {
                    showingUpdateConfirmation = true
                } else {
                    // Değişiklik yoksa direkt kapat
                    showingUpdateForm = false
                }
            }
            .font(CustomFont.bold(size: 16))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isUpdateButtonEnabled ? Color.logo : Color.gray.opacity(0.4))
            )
            .disabled(!isUpdateButtonEnabled || isLoading)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                }
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
    }
    
    private var isUpdateButtonEnabled: Bool {
        selectedBrandIndex != nil && 
        !selectedModel.isEmpty && 
        !plateNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        validateTurkishPlate(plateNumber)
    }
    
    private func searchBarView(text: Binding<String>, placeholder: String) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
            
            TextField(placeholder, text: text)
                .font(CustomFont.regular(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func brandCardView(brand: MockVehicleBrand, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: "car.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? .logo : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(brand.name)
                        .font(CustomFont.bold(size: 16))
                        .foregroundColor(.primary)

                    Text("\(brand.models.count) model")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.logo)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.logo.opacity(isSelected ? 1 : 0), lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func modelCardView(model: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(model)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.logo)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.logo.opacity(isSelected ? 1 : 0), lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func initializeFormData() {
        // Mevcut araç bilgileriyle formu başlat
        vehicleName = vehicle.name ?? "" // Mevcut araç ismi
        plateNumber = vehicle.plate
        
        // Brand index'ini bul
        if let brandIndex = vehicleBrands.firstIndex(where: { $0.name == vehicle.brand }) {
            selectedBrandIndex = brandIndex
            selectedModel = vehicle.model
        } else {
            // Eğer brand bulunamazsa, ilk brand'i seç ve model'i boş bırak
            selectedBrandIndex = 0
            selectedModel = ""
        }
        
        // Validation'ı başlangıçta çalıştır
        validateTurkishPlate(plateNumber)
    }
    
    // Form değişikliklerini kontrol et
    private func hasFormChanges() -> Bool {
        let originalBrandIndex = vehicleBrands.firstIndex(where: { $0.name == vehicle.brand })
        let originalVehicleName = vehicle.name ?? ""
        
        // Herhangi bir değişiklik var mı?
        return selectedBrandIndex != originalBrandIndex ||
               selectedModel != vehicle.model ||
               plateNumber != vehicle.plate ||
               vehicleName != originalVehicleName
    }
    
    // MARK: - Computed Properties
    private var interiorPhotos: [VehicleImage] {
        // Fotoğrafları filename'e göre kategorize et
        let interior = vehicleImages.filter { image in
            let filename = image.filename.lowercased()
            return filename.contains("interior") || 
                   filename.contains("ic") || 
                   filename.contains("icmekan") || 
                   filename.contains("iç")
        }
        
        // Eğer filename'e göre ayırma başarısız olduysa, ilk yarısını iç mekan yap
        if interior.isEmpty && !vehicleImages.isEmpty {
            let midPoint = vehicleImages.count / 2
            let firstHalf = Array(vehicleImages.prefix(midPoint))
            print("📸 Filename'e göre kategorize edilemedi, ilk \(firstHalf.count) fotoğraf iç mekan olarak ayarlandı")
            return firstHalf
        }
        
        print("📸 Filename'e göre \(interior.count) iç mekan fotoğrafı bulundu")
        return interior
    }
    
    private var exteriorPhotos: [VehicleImage] {
        // Fotoğrafları filename'e göre kategorize et
        let exterior = vehicleImages.filter { image in
            let filename = image.filename.lowercased()
            return filename.contains("exterior") || 
                   filename.contains("dis") || 
                   filename.contains("dismekan") || 
                   filename.contains("dış") ||
                   filename.contains("outer")
        }
        
        // Eğer filename'e göre ayırma başarısız olduysa, ikinci yarısını dış mekan yap
        if exterior.isEmpty && !vehicleImages.isEmpty {
            let midPoint = vehicleImages.count / 2
            let secondHalf = Array(vehicleImages.suffix(from: midPoint))
            print("📸 Filename'e göre kategorize edilemedi, son \(secondHalf.count) fotoğraf dış mekan olarak ayarlandı")
            return secondHalf
        }
        
        print("📸 Filename'e göre \(exterior.count) dış mekan fotoğrafı bulundu")
        return exterior
    }
    
    // MARK: - Helper Methods
    private func validateTurkishPlate(_ plate: String) -> Bool {
        // Boşlukları temizle ve büyük harfe çevir
        let cleanPlate = plate.replacingOccurrences(of: " ", with: "").uppercased()
        
        // Minimum 7, maksimum 8 karakter
        guard cleanPlate.count >= 7 && cleanPlate.count <= 8 else {
            plateValidationMessage = "Plaka 7-8 karakter olmalıdır"
            return false
        }
        
        // İlk 2 karakter rakam olmalı (01-81 arası il kodu)
        let cityCode = String(cleanPlate.prefix(2))
        guard let cityCodeInt = Int(cityCode), cityCodeInt >= 1 && cityCodeInt <= 81 else {
            plateValidationMessage = "İlk 2 hane geçerli il kodu olmalıdır (01-81)"
            return false
        }
        
        // Geri kalan kısmı analiz et
        let remaining = String(cleanPlate.dropFirst(2))
        
        // Harf ve rakam kısımlarını ayır
        var letters = ""
        var numbers = ""
        var lettersPart = true
        
        for char in remaining {
            if char.isLetter && lettersPart {
                letters.append(char)
            } else if char.isNumber {
                lettersPart = false
                numbers.append(char)
            } else {
                plateValidationMessage = "Plakada geçersiz karakter bulundu"
                return false
            }
        }
        
        // Harf sayısı kontrolü (1-3 arası)
        guard letters.count >= 1 && letters.count <= 3 else {
            plateValidationMessage = "Harf sayısı 1-3 arasında olmalıdır"
            return false
        }
        
        // Rakam sayısı kontrolü
        let expectedNumberCounts: [Int]
        switch letters.count {
        case 1:
            expectedNumberCounts = [4] // 1 harf → 4 rakam
        case 2:
            expectedNumberCounts = [3, 4] // 2 harf → 3 veya 4 rakam
        case 3:
            expectedNumberCounts = [2] // 3 harf → 2 rakam
        default:
            plateValidationMessage = "Geçersiz harf sayısı"
            return false
        }
        
        guard expectedNumberCounts.contains(numbers.count) else {
            plateValidationMessage = "\(letters.count) harf için \(expectedNumberCounts.map(String.init).joined(separator: " veya ")) rakam olmalıdır"
            return false
        }
        
        plateValidationMessage = ""
        return true
    }
    
    private func formatPlate(_ plate: String) -> String {
        // Boşlukları temizle ve büyük harfe çevir
        let cleanPlate = plate.replacingOccurrences(of: " ", with: "").uppercased()
        
        guard cleanPlate.count >= 3 else { return cleanPlate }
        
        // İlk 2 rakam
        let cityCode = String(cleanPlate.prefix(2))
        let remaining = String(cleanPlate.dropFirst(2))
        
        // Harf ve rakam kısımlarını ayır
        var letters = ""
        var numbers = ""
        
        for char in remaining {
            if char.isLetter && numbers.isEmpty {
                letters.append(char)
            } else if char.isNumber {
                numbers.append(char)
            }
        }
        
        // Format: "34 ABC 123" şeklinde
        if letters.isEmpty {
            return cityCode
        } else if numbers.isEmpty {
            return "\(cityCode) \(letters)"
        } else {
            return "\(cityCode) \(letters) \(numbers)"
        }
    }

    private func loadVehicleDetails() async {
        print("📸 MyVehicleDetailView: loadVehicleDetails başladı")
        print("📸 Araç ID: \(vehicle.apiId ?? "N/A")")
        print("📸 Mevcut fotoğraf sayısı: \(vehicle.images.count)")
        
        // Mevcut fotoğrafları detaylı logla
        for (index, image) in vehicle.images.enumerated() {
            print("📸 Fotoğraf \(index + 1): \(image.filename) - URL: \(image.url)")
        }
        
        await MainActor.run {
            vehicleImages = vehicle.images // API'den gelen fotoğraflar
            
            // Computed properties'i test et
            print("📸 İç mekan fotoğraf sayısı: \(interiorPhotos.count)")
            print("📸 Dış mekan fotoğraf sayısı: \(exteriorPhotos.count)")
            
            if exteriorPhotos.isEmpty && vehicleImages.count > 0 {
                print("⚠️ Uyarı: Dış mekan fotoğrafı yok ama toplam fotoğraf var")
                print("⚠️ Toplam fotoğraf: \(vehicleImages.count)")
                print("⚠️ Bu fotoğrafların hepsi iç mekan olarak kategorize edildi")
            }
        }
    }
    

    
    private func updateVehicle() async {
        guard let brandIndex = selectedBrandIndex else { 
            errorMessage = "Marka seçilmedi"
            showError = true
            return 
        }
        
        guard !selectedModel.isEmpty else {
            errorMessage = "Model seçilmedi"
            showError = true
            return
        }
        
        guard !plateNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Plaka bilgisi girilmedi"
            showError = true
            return
        }
        
        guard validateTurkishPlate(plateNumber) else {
            errorMessage = "Geçersiz plaka formatı"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            let vehicleId = vehicle.apiId ?? "mock_vehicle_id"
            let _ = try await vehicleService.updateVehicle(
                vehicleId: vehicleId,
                model: selectedModel,
                plate: plateNumber,
                brandName: vehicleBrands[brandIndex].name,
                vehicleName: vehicleName.isEmpty ? "" : vehicleName
            )
            
            await MainActor.run {
                isLoading = false
                showingUpdateForm = false
                // Optionally refresh vehicle data here
            }
            
            print("✅ Araç başarıyla güncellendi")
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
            print("❌ updateVehicle Error: \(error)")
        }
    }
    
    private func deleteVehicle() async {
        isLoading = true
        
        do {
            let vehicleId = vehicle.apiId ?? "mock_vehicle_id"
            try await vehicleService.deleteVehicle(vehicleId: vehicleId)
            
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    // Helper function to convert VehicleImage to UIImage
    private func convertToUIImage(_ vehicleImages: [VehicleImage]) -> UIImage? {
        return vehicleImages.first.flatMap { vehicleImage in
            // URL'den UIImage yükleme burada yapılabilir, şimdilik placeholder
            UIImage(named: "temp_car")
        }
    }
}
