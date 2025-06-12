import SwiftUI
import PhotosUI

// MARK: - Add Vehicle Steps
enum AddVehicleStep: Int, CaseIterable {
    case brand = 0
    case model = 1
    case plate = 2
    case photos = 3
    case name = 4
    case complete = 5
    
    var title: String {
        switch self {
        case .brand:
            return "Marka Seçimi"
        case .model:
            return "Model Seçimi"
        case .plate:
            return "Plaka Bilgisi"
        case .photos:
            return "Fotoğraflar"
        case .name:
            return "Araç İsmi"
        case .complete:
            return "Tamamlandı"
        }
    }
    
    var description: String {
        switch self {
        case .brand:
            return "Aracınızın markası nedir?"
        case .model:
            return "Aracınızın modeli nedir?"
        case .plate:
            return "Aracınızın plakası nedir?"
        case .photos:
            return "Aracınızın fotoğraflarını yüklemek istiyoruz"
        case .name:
            return "Aracınıza bir isim vermek ister misiniz?"
        case .complete:
            return "Araç başarıyla eklendi!"
        }
    }
}

struct AddVehicleView: View {
    @StateObject private var vehicleService = VehicleService.shared
    @EnvironmentObject var appState: AppState

    @State private var currentStep: AddVehicleStep = .brand
    @State private var selectedBrandIndex: Int?
    @State private var selectedModel: String = ""
    @State private var plateNumber: String = ""
    @State private var plateValidationMessage: String = ""
    @State private var vehicleName: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Photo states
    @State private var selectedInteriorPhotos: [UIImage] = []
    @State private var selectedExteriorPhotos: [UIImage] = []
    @State private var showingInteriorPhotoPicker = false
    @State private var showingExteriorPhotoPicker = false
    @State private var interiorPhotoItems: [PhotosPickerItem] = []
    @State private var exteriorPhotoItems: [PhotosPickerItem] = []
    
    // Search states
    @State private var brandSearchText = ""
    @State private var modelSearchText = ""
    
    let onComplete: () -> Void
    
    var filteredBrands: [MockVehicleBrand] {
        if brandSearchText.isEmpty {
            return vehicleBrands
        } else {
            return vehicleBrands.filter { $0.name.localizedCaseInsensitiveContains(brandSearchText) }
        }
    }
    
    var filteredModels: [String] {
        guard let brandIndex = selectedBrandIndex else { return [] }
        let models = vehicleBrands[brandIndex].models
        
        if modelSearchText.isEmpty {
            return models.sorted()
        } else {
            return models.filter { $0.localizedCaseInsensitiveContains(modelSearchText) }.sorted()
        }
    }
    
    var progress: Double {
        return Double(currentStep.rawValue) / Double(AddVehicleStep.allCases.count - 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with progress
                    headerView
            
            // Main content
            VStack(spacing: 0) {
                stepContentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom button
                bottomButtonView
            }
            }
            .background(Color("BackgroundColor"))
        .onChange(of: interiorPhotoItems) { _, newItems in
            loadPhotos(from: newItems, isInterior: true)
        }
        .onChange(of: exteriorPhotoItems) { _, newItems in
            loadPhotos(from: newItems, isInterior: false)
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
        HStack {
                Button("İptal") {
                    onComplete()
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Araç Ekle")
                    .font(CustomFont.bold(size: 18))
                
                Spacer()
                
                // Invisible button for balance
                Button("İptal") {
                    onComplete()
                }
                .opacity(0)
                .disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Adım \(currentStep.rawValue + 1) / \(AddVehicleStep.allCases.count - 1)")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                    
            Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(.logo)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.logo))
                    .scaleEffect(y: 2)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Step Content View
    @ViewBuilder
    private var stepContentView: some View {
        switch currentStep {
        case .brand:
            brandSelectionView
        case .model:
            modelSelectionView
        case .plate:
            plateEntryView
        case .photos:
            photoSelectionView
        case .name:
            nameEntryView
        case .complete:
            completionView
        }
    }
    
    // MARK: - Brand Selection View
    private var brandSelectionView: some View {
        VStack(spacing: 24) {
            stepHeaderView(
                title: currentStep.title,
                description: currentStep.description,
                icon: "car.fill"
            )
            
            // Search bar
            searchBarView(text: $brandSearchText, placeholder: "Marka ara...")
            
            // Brand list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(filteredBrands.enumerated()), id: \.offset) { originalIndex, brand in
                        let actualIndex = vehicleBrands.firstIndex(where: { $0.id == brand.id }) ?? 0
                        
                        brandCardView(brand: brand, isSelected: selectedBrandIndex == actualIndex) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedBrandIndex = actualIndex
                                brandSearchText = ""
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Model Selection View
    private var modelSelectionView: some View {
        VStack(spacing: 24) {
            stepHeaderView(
                title: currentStep.title,
                description: currentStep.description,
                icon: "car.2.fill"
            )
            
            if let brandIndex = selectedBrandIndex {
                Text("Seçilen Marka: \(vehicleBrands[brandIndex].name)")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.logo)
                    .padding(.horizontal, 20)
            }
            
            // Search bar
            searchBarView(text: $modelSearchText, placeholder: "Model ara...")
            
            // Model list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredModels, id: \.self) { model in
                        modelCardView(model: model, isSelected: selectedModel == model) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedModel = model
                                modelSearchText = ""
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Plate Entry View
    private var plateEntryView: some View {
        VStack(spacing: 32) {
            stepHeaderView(
                title: currentStep.title,
                description: currentStep.description,
                icon: "rectangle.and.text.magnifyingglass"
            )
            
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
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Photo Selection View
    private var photoSelectionView: some View {
        VStack(spacing: 24) {
            stepHeaderView(
                title: currentStep.title,
                description: currentStep.description,
                icon: "camera.fill"
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Interior photos section
                    photoSectionView(
                        title: "İç Mekan Fotoğrafları",
                        subtitle: "4 adet fotoğraf seçin",
                        photos: selectedInteriorPhotos,
                        maxCount: 4,
                        onAddPhoto: { 
                    interiorPhotoItems = []
                    showingInteriorPhotoPicker = true 
                },
                        onRemovePhoto: { index in
                            selectedInteriorPhotos.remove(at: index)
                        }
                    )
                    
                    // Exterior photos section
                    photoSectionView(
                        title: "Dış Mekan Fotoğrafları",
                        subtitle: "4 adet fotoğraf seçin",
                        photos: selectedExteriorPhotos,
                        maxCount: 4,
                        onAddPhoto: { 
                    exteriorPhotoItems = []
                    showingExteriorPhotoPicker = true 
                },
                        onRemovePhoto: { index in
                            selectedExteriorPhotos.remove(at: index)
                        }
                    )
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .photosPicker(isPresented: $showingInteriorPhotoPicker, selection: $interiorPhotoItems, maxSelectionCount: 4, matching: .images)
        .photosPicker(isPresented: $showingExteriorPhotoPicker, selection: $exteriorPhotoItems, maxSelectionCount: 4, matching: .images)
        .onChange(of: interiorPhotoItems) { items in
            print("🔄 Interior photo items değişti: \(items.count)")
            if !items.isEmpty && selectedInteriorPhotos.count != items.count {
                loadPhotos(from: items, isInterior: true)
            }
        }
        .onChange(of: exteriorPhotoItems) { items in
            print("🔄 Exterior photo items değişti: \(items.count)")
            if !items.isEmpty && selectedExteriorPhotos.count != items.count {
                loadPhotos(from: items, isInterior: false)
            }
        }
    }
    
    // MARK: - Name Entry View
    private var nameEntryView: some View {
        VStack(spacing: 32) {
            stepHeaderView(
                title: currentStep.title,
                description: currentStep.description,
                icon: "textformat"
            )
            
            VStack(spacing: 16) {
                TextField("Opsiyonel araç ismi", text: $vehicleName)
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
                            .stroke(Color.logo.opacity(vehicleName.isEmpty ? 0 : 0.5), lineWidth: 2)
                    )
                
                Text("Bu alan opsiyoneldir, boş bırakabilirsiniz")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 16) {
                Text("Harika!")
                    .font(CustomFont.bold(size: 28))
                    .foregroundColor(.primary)
                
                Text("Aracınız başarıyla eklendi")
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Views
    private func stepHeaderView(title: String, description: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.logo)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(CustomFont.bold(size: 24))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
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
        .padding(.horizontal, 20)
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
    
    private func photoSectionView(
        title: String,
        subtitle: String,
        photos: [UIImage],
        maxCount: Int,
        onAddPhoto: @escaping () -> Void,
        onRemovePhoto: @escaping (Int) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, image in
                    photoCardView(image: image) {
                        onRemovePhoto(index)
                    }
                }
                
                if photos.count < maxCount {
                    addPhotoCardView(action: onAddPhoto)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func photoCardView(image: UIImage, onRemove: @escaping () -> Void) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
                .cornerRadius(12)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.6)))
            }
            .padding(8)
        }
    }
    
    private func addPhotoCardView(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 32))
                    .foregroundColor(.logo)
                
                Text("Fotoğraf Ekle")
                    .font(CustomFont.medium(size: 12))
                    .foregroundColor(.logo)
            }
            .frame(height: 120)
                            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.logo.opacity(0.1))
                                    .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.logo.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
                )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Bottom Button View
    private var bottomButtonView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            HStack(spacing: 16) {
                if currentStep != .brand && currentStep != .complete {
                    Button("Geri") {
                        withAnimation(.spring(response: 0.4)) {
                            goToPreviousStep()
                        }
                    }
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.secondary)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                
                Button(bottomButtonTitle) {
                    withAnimation(.spring(response: 0.4)) {
                        handleBottomButtonTap()
                    }
                }
                .font(CustomFont.bold(size: 16))
                .foregroundColor(.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isBottomButtonEnabled ? Color.logo : Color.gray.opacity(0.4))
                )
                .disabled(!isBottomButtonEnabled || isLoading)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.white)
    }
    
    private var bottomButtonTitle: String {
        if isLoading {
            return "İşleniyor..."
        }
        
        switch currentStep {
        case .brand, .model, .plate, .photos:
            return "Devam Et"
        case .name:
            return "Aracı Oluştur"
        case .complete:
            return "Tamamla"
        }
    }
    
    private var isBottomButtonEnabled: Bool {
        switch currentStep {
        case .brand:
            return selectedBrandIndex != nil
        case .model:
            return !selectedModel.isEmpty
        case .plate:
            return !plateNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && validateTurkishPlate(plateNumber)
        case .photos:
            return selectedInteriorPhotos.count == 4 && selectedExteriorPhotos.count == 4
        case .name:
            return true // Name is optional
        case .complete:
            return true
        }
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
    
    private func goToPreviousStep() {
        if currentStep.rawValue > 0 {
            currentStep = AddVehicleStep(rawValue: currentStep.rawValue - 1) ?? .brand
        }
    }
    
    private func handleBottomButtonTap() {
        switch currentStep {
        case .brand, .model, .plate, .photos:
            currentStep = AddVehicleStep(rawValue: currentStep.rawValue + 1) ?? .complete
        case .name:
            Task {
                await createVehicle()
            }
        case .complete:
            onComplete()
        }
    }
    
    private func createVehicle() async {
        guard let brandIndex = selectedBrandIndex else { return }
        
        isLoading = true
        
        do {
            // 1. Create vehicle
            let vehicleData = try await vehicleService.createVehicle(
                model: selectedModel,
                plate: plateNumber,
                brandName: vehicleBrands[brandIndex].name,
                vehicleName: vehicleName.isEmpty ? "" : vehicleName
            )
            
            // 2. Combine all photos (interior first, then exterior)
            var allPhotos: [UIImage] = []
            allPhotos.append(contentsOf: selectedInteriorPhotos)
            allPhotos.append(contentsOf: selectedExteriorPhotos)
            
            // 3. Upload photos one by one (more reliable than batch)
            if !allPhotos.isEmpty {
                print("📸 \(allPhotos.count) fotoğraf tek tek yüklenecek...")
                var uploadedCount = 0
                
                for (index, photo) in allPhotos.enumerated() {
                    do {
                        let _ = try await vehicleService.uploadVehicleImage(
                            vehicleId: vehicleData.id,
                            image: photo
                        )
                        uploadedCount += 1
                        print("✅ Fotoğraf \(index + 1)/\(allPhotos.count) yüklendi")
                    } catch {
                        print("❌ Fotoğraf \(index + 1) yüklenemedi: \(error)")
                        // Devam et, diğer fotoğrafları yüklemeye çalış
                    }
                }
                
                print("✅ Toplam \(uploadedCount)/\(allPhotos.count) fotoğraf yüklendi")
            }
            
            // 4. AppState'i güncelle - araç listesini yenile
            await appState.loadUserVehicles(forceRefresh: true)
            
            await MainActor.run {
                isLoading = false
                currentStep = .complete
                print("✅ Araç başarıyla oluşturuldu ve AppState güncellendi")
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                print("❌ Araç oluşturma hatası: \(error)")
            }
        }
    }
    
    private func loadPhotos(from items: [PhotosPickerItem], isInterior: Bool) {
        print("📸 loadPhotos başladı - \(isInterior ? "İç" : "Dış") fotoğraflar: \(items.count)")
        
        // Loading state'i başlat
        Task { @MainActor in
            isLoading = true
        }
        
        Task {
            var images: [UIImage] = []
            var successCount = 0
            var failCount = 0
            
            for (index, item) in items.enumerated() {
                print("📸 Fotoğraf \(index + 1)/\(items.count) yükleniyor...")
                
                do {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        print("📸 Data yüklendi: \(data.count) bytes")
                        
                        if let image = UIImage(data: data) {
                            print("📸 UIImage oluşturuldu: \(image.size)")
                            images.append(image)
                            successCount += 1
                        } else {
                            print("❌ UIImage oluşturulamadı")
                            failCount += 1
                        }
                    } else {
                        print("❌ Data yüklenemedi")
                        failCount += 1
                    }
                } catch {
                    print("❌ Fotoğraf yükleme hatası: \(error)")
                    failCount += 1
                }
            }
            
            print("📸 Fotoğraf yükleme tamamlandı - Başarılı: \(successCount), Başarısız: \(failCount)")
            
            await MainActor.run {
                if isInterior {
                    selectedInteriorPhotos = images
                    print("📸 İç mekan fotoğrafları set edildi: \(selectedInteriorPhotos.count)")
                } else {
                    selectedExteriorPhotos = images
                    print("📸 Dış mekan fotoğrafları set edildi: \(selectedExteriorPhotos.count)")
                }
                
                // Loading state'i bitir
                isLoading = false
                
                // Hata varsa kullanıcıya bildir
                if failCount > 0 {
                    errorMessage = "\(failCount) fotoğraf yüklenemedi. Lütfen tekrar deneyin."
                    showError = true
                }
            }
        }
    }
}
