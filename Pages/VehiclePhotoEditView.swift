import SwiftUI
import PhotosUI

struct VehiclePhotoEditView: View {
    let vehicle: Vehicle
    @Binding var vehicleImages: [VehicleImage]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vehicleService = VehicleService.shared
    @StateObject private var authService = AuthService.shared
    
    @State private var interiorImages: [VehicleImage] = []
    @State private var exteriorImages: [VehicleImage] = []
    @State private var selectedInteriorItems: [PhotosPickerItem] = []
    @State private var selectedExteriorItems: [PhotosPickerItem] = []
    
    // Pending changes - güncelle tuşuna basılana kadar bekleyecek
    @State private var pendingDeletedImages: Set<String> = []
    @State private var pendingNewInteriorImages: [UIImage] = []
    @State private var pendingNewExteriorImages: [UIImage] = []
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let maxPhotosPerCategory = 4
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    
    private var hasChanges: Bool {
        !pendingDeletedImages.isEmpty || !pendingNewInteriorImages.isEmpty || !pendingNewExteriorImages.isEmpty
    }
    
    private var canSave: Bool {
        let finalInteriorCount = (interiorImages.count - interiorImages.filter { pendingDeletedImages.contains($0.id) }.count) + pendingNewInteriorImages.count
        let finalExteriorCount = (exteriorImages.count - exteriorImages.filter { pendingDeletedImages.contains($0.id) }.count) + pendingNewExteriorImages.count
        
        return finalInteriorCount == maxPhotosPerCategory && finalExteriorCount == maxPhotosPerCategory
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentSection
            bottomSection
        }
        .background(Color("BackgroundColor"))
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            print("==================================================")
            print("✅ VehiclePhotoEditView AÇILDI!")
            print("🚗 Vehicle: \(vehicle.brand) \(vehicle.model)")
            print("📋 Plaka: \(vehicle.plate)")
            print("🆔 Vehicle API ID: \(vehicle.apiId ?? "NIL")")
            print("📸 Images count: \(vehicleImages.count)")
            
            // Mevcut fotoğrafların ID'lerini logla
            for (index, image) in vehicleImages.enumerated() {
                print("📷 Image \(index): ID=\(image.id), URL=\(image.url)")
            }
            print("==================================================")
            loadExistingPhotos()
        }
        .onChange(of: selectedInteriorItems) { _, newItems in
            addPendingPhotos(items: newItems, isInterior: true)
        }
        .onChange(of: selectedExteriorItems) { _, newItems in
            addPendingPhotos(items: newItems, isInterior: false)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Button {
                print("🔴 İptal butonu basıldı")
                dismiss()
            } label: {
                Text("İptal")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Fotoğrafları Düzenle")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button {
                print("🟢 Kaydet butonu basıldı")
                saveChanges()
            } label: {
                Text("Kaydet")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(canSave ? .logo : .gray)
            }
            .disabled(!canSave || isLoading || !hasChanges)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleSection
                interiorPhotoSection
                exteriorPhotoSection
                if hasChanges {
                    changesPreviewSection
                }
                validationSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 50))
                .foregroundColor(.logo)
            
            VStack(spacing: 8) {
                Text("Araç Fotoğraflarını Düzenle")
                    .font(CustomFont.bold(size: 24))
                    .foregroundColor(.primary)
                
                Text("Her kategori için tam olarak 4 fotoğraf gereklidir")
                    .font(CustomFont.regular(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Interior Photo Section
    private var interiorPhotoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("İç Mekan Fotoğrafları")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.primary)
                    
                    let currentCount = getCurrentPhotoCount(for: interiorImages, isInterior: true)
                    Text("\(currentCount)/\(maxPhotosPerCategory) fotoğraf")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(currentCount == maxPhotosPerCategory ? .green : .secondary)
                }
                
                Spacer()
                
                let currentCount = getCurrentPhotoCount(for: interiorImages, isInterior: true)
                if currentCount < maxPhotosPerCategory {
                    PhotosPicker(
                        selection: $selectedInteriorItems,
                        maxSelectionCount: maxPhotosPerCategory - currentCount,
                        matching: .images
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.logo)
                    }
                }
            }
            
            photoGrid(images: interiorImages, pendingImages: pendingNewInteriorImages, isInterior: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Exterior Photo Section
    private var exteriorPhotoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dış Mekan Fotoğrafları")
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.primary)
                    
                    let currentCount = getCurrentPhotoCount(for: exteriorImages, isInterior: false)
                    Text("\(currentCount)/\(maxPhotosPerCategory) fotoğraf")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(currentCount == maxPhotosPerCategory ? .green : .secondary)
                }
                
                Spacer()
                
                let currentCount = getCurrentPhotoCount(for: exteriorImages, isInterior: false)
                if currentCount < maxPhotosPerCategory {
                    PhotosPicker(
                        selection: $selectedExteriorItems,
                        maxSelectionCount: maxPhotosPerCategory - currentCount,
                        matching: .images
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.logo)
                    }
                }
            }
            
            photoGrid(images: exteriorImages, pendingImages: pendingNewExteriorImages, isInterior: false)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Photo Grid
    private func photoGrid(images: [VehicleImage], pendingImages: [UIImage], isInterior: Bool) -> some View {
        LazyVGrid(columns: columns, spacing: 8) {
            // Mevcut fotoğraflar
            ForEach(images) { image in
                let isDeleted = pendingDeletedImages.contains(image.id)
                photoCard(image: image, isDeleted: isDeleted, isInterior: isInterior)
            }
            
            // Pending yeni fotoğraflar
            ForEach(Array(pendingImages.enumerated()), id: \.offset) { index, image in
                pendingPhotoCard(image: image, index: index, isInterior: isInterior)
            }
            
            // Boş slotlar
            let currentCount = getCurrentPhotoCount(for: images, isInterior: isInterior)
            if currentCount < maxPhotosPerCategory {
                ForEach(currentCount..<maxPhotosPerCategory, id: \.self) { _ in
                    emptyPhotoSlot(isInterior: isInterior)
                }
            }
        }
    }
    
    // MARK: - Photo Card
    private func photoCard(image: VehicleImage, isDeleted: Bool, isInterior: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: image.url)) { loadedImage in
                loadedImage
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
            .frame(maxWidth: .infinity, maxHeight: 120)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .cornerRadius(12)
            .opacity(isDeleted ? 0.3 : 1.0)
            .overlay(
                isDeleted ? 
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 2)
                    .overlay(
                        Text("SİLİNECEK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    ) : nil
            )
            
            Button {
                if isDeleted {
                    pendingDeletedImages.remove(image.id)
                    print("↩️ Silme iptal edildi: \(image.id)")
                    print("📷 Fotoğraf URL: \(image.url)")
                } else {
                    pendingDeletedImages.insert(image.id)
                    print("🗑️ Silme için işaretlendi: \(image.id)")
                    print("📷 Fotoğraf URL: \(image.url)")
                }
                print("🗂️ Pending deleted images: \(Array(pendingDeletedImages))")
            } label: {
                Image(systemName: isDeleted ? "arrow.uturn.left.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Circle().fill(isDeleted ? Color.blue : Color.red))
            }
            .padding(6)
        }
    }
    
    // MARK: - Pending Photo Card
    private func pendingPhotoCard(image: UIImage, index: Int, isInterior: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 120)
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2)
                        .overlay(
                            Text("YENİ")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(4)
                        )
                )
            
            Button {
                if isInterior {
                    pendingNewInteriorImages.remove(at: index)
                } else {
                    pendingNewExteriorImages.remove(at: index)
                }
                print("🗑️ Pending fotoğraf kaldırıldı")
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.red))
            }
            .padding(6)
        }
    }
    
    // MARK: - Empty Photo Slot
    private func emptyPhotoSlot(isInterior: Bool) -> some View {
        PhotosPicker(
            selection: isInterior ? $selectedInteriorItems : $selectedExteriorItems,
            maxSelectionCount: 1,
            matching: .images
        ) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: 120)
                .aspectRatio(1, contentMode: .fill)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        Text("Ekle")
                            .font(CustomFont.regular(size: 12))
                            .foregroundColor(.gray)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
        }
    }
    
    // MARK: - Changes Preview Section
    private var changesPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bekleyen Değişiklikler")
                .font(CustomFont.bold(size: 16))
                .foregroundColor(.primary)
            
            if !pendingDeletedImages.isEmpty {
                Text("🗑️ Silinecek: \(pendingDeletedImages.count) fotoğraf")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.red)
            }
            
            if !pendingNewInteriorImages.isEmpty {
                Text("➕ İç mekan eklenecek: \(pendingNewInteriorImages.count) fotoğraf")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.green)
            }
            
            if !pendingNewExteriorImages.isEmpty {
                Text("➕ Dış mekan eklenecek: \(pendingNewExteriorImages.count) fotoğraf")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    // MARK: - Validation Section
    private var validationSection: some View {
        VStack(spacing: 12) {
            let interiorCount = getCurrentPhotoCount(for: interiorImages, isInterior: true)
            let exteriorCount = getCurrentPhotoCount(for: exteriorImages, isInterior: false)
            
            HStack(spacing: 12) {
                Image(systemName: interiorCount == maxPhotosPerCategory ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(interiorCount == maxPhotosPerCategory ? .green : .red)
                
                Text("İç Mekan: \(interiorCount)/\(maxPhotosPerCategory)")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Image(systemName: exteriorCount == maxPhotosPerCategory ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(exteriorCount == maxPhotosPerCategory ? .green : .red)
                
                Text("Dış Mekan: \(exteriorCount)/\(maxPhotosPerCategory)")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(canSave ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        )
    }
    
    // MARK: - Bottom Section
    private var bottomSection: some View {
        VStack(spacing: 16) {
            if !canSave {
                Text("Her kategori için tam olarak 4 fotoğraf gereklidir")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            if !hasChanges {
                Text("Değişiklik yapmak için fotoğraf ekleyin veya silin")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                print("💾 Ana kaydet butonu basıldı")
                saveChanges()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(isLoading ? "Kaydediliyor..." : "Değişiklikleri Kaydet")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSave && hasChanges && !isLoading ? Color.logo : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!canSave || !hasChanges || isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .background(Color.white)
    }
    
    // MARK: - Helper Methods
    private func loadExistingPhotos() {
        let totalImages = vehicleImages
        let halfCount = min(maxPhotosPerCategory, totalImages.count)
        
        interiorImages = Array(totalImages.prefix(halfCount))
        
        if totalImages.count > maxPhotosPerCategory {
            exteriorImages = Array(totalImages.suffix(from: halfCount))
        } else {
            exteriorImages = []
        }
        
        print("📸 Fotoğraflar yüklendi - İç: \(interiorImages.count), Dış: \(exteriorImages.count)")
    }
    
    private func getCurrentPhotoCount(for images: [VehicleImage], isInterior: Bool) -> Int {
        let existingCount = images.filter { !pendingDeletedImages.contains($0.id) }.count
        let pendingCount = isInterior ? pendingNewInteriorImages.count : pendingNewExteriorImages.count
        return existingCount + pendingCount
    }
    
    private func compressImages(_ images: [UIImage]) -> [UIImage] {
        return images.compactMap { image in
            print("🔍 Orijinal resim boyutu: \(image.size)")
            
            // Daha küçük maksimum boyut
            let maxWidth: CGFloat = 800
            let maxHeight: CGFloat = 800
            
            // Orantılı resize
            let scale = min(maxWidth / image.size.width, maxHeight / image.size.height)
            
            var finalImage: UIImage
            
            if scale < 1 {
                let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0) // scale 1.0 for better compression
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                finalImage = resizedImage ?? image
                print("🗜️ Resim yeniden boyutlandırıldı: \(image.size) -> \(newSize)")
            } else {
                finalImage = image
                print("🗜️ Resim boyutu uygun: \(image.size)")
            }
            
            // JPEG olarak sıkıştır ve boyut kontrol et
            var quality: CGFloat = 0.5 // Daha düşük quality
            var jpegData = finalImage.jpegData(compressionQuality: quality)
            
            // Eğer hala 1MB'dan büyükse daha da sıkıştır
            let maxFileSize = 1024 * 1024 // 1MB
            while let data = jpegData, data.count > maxFileSize && quality > 0.1 {
                quality -= 0.1
                jpegData = finalImage.jpegData(compressionQuality: quality)
                print("🗜️ Quality düşürüldü: \(quality) - Boyut: \(data.count) bytes")
            }
            
            if let finalData = jpegData, let compressedImage = UIImage(data: finalData) {
                print("✅ Final boyut: \(finalData.count) bytes (\(String(format: "%.1f", Double(finalData.count) / 1024.0)) KB)")
                return compressedImage
            } else {
                print("❌ Sıkıştırma başarısız!")
                return nil
            }
        }
    }
    
    private func addPendingPhotos(items: [PhotosPickerItem], isInterior: Bool) {
        guard !items.isEmpty else { return }
        
        Task {
            for item in items {
                do {
                    if let data = try await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        
                        await MainActor.run {
                            if isInterior {
                                pendingNewInteriorImages.append(image)
                                selectedInteriorItems = []
                            } else {
                                pendingNewExteriorImages.append(image)
                                selectedExteriorItems = []
                            }
                        }
                    }
                } catch {
                    print("❌ Fotoğraf yükleme hatası: \(error)")
                }
            }
        }
    }
    
    private func saveChanges() {
        guard hasChanges else { return }
        
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let carId = vehicle.apiId ?? "684859de0cd1361bd1a03a81"
                print("🔧 API işlemleri başlıyor - Car ID: \(carId)")
                print("🗑️ Silinecek fotoğraf sayısı: \(pendingDeletedImages.count)")
                print("📷 Silinecek fotoğraf ID'leri: \(Array(pendingDeletedImages))")
                
                // 1. Önce silinecek fotoğrafları sil
                for imageId in pendingDeletedImages {
                    print("🗑️ Siliniyor: \(imageId)")
                    print("🔗 Tam URL: http://localhost:8080/cars/\(carId)/images/\(imageId)")
                    try await deleteImage(carId: carId, imageId: imageId)
                }
                
                // 2. Sonra yeni fotoğrafları compress edip yükle
                if !pendingNewInteriorImages.isEmpty || !pendingNewExteriorImages.isEmpty {
                    let allNewImages = pendingNewInteriorImages + pendingNewExteriorImages
                    print("📸 Yüklenecek: \(allNewImages.count) fotoğraf")
                    
                    // Resimleri sıkıştır
                    let compressedImages = compressImages(allNewImages)
                    try await uploadImages(carId: carId, images: compressedImages)
                }
                
                // 3. Ana view'daki verileri güncelle
                await MainActor.run {
                    // Silinen fotoğrafları kaldır
                    interiorImages.removeAll { pendingDeletedImages.contains($0.id) }
                    exteriorImages.removeAll { pendingDeletedImages.contains($0.id) }
                    
                    // Pending değişiklikleri temizle
                    pendingDeletedImages.removeAll()
                    pendingNewInteriorImages.removeAll()
                    pendingNewExteriorImages.removeAll()
                    
                    // VehicleImages'ı güncelle
                    vehicleImages = interiorImages + exteriorImages
                    
                    isLoading = false
                    print("✅ Tüm değişiklikler kaydedildi!")
                    dismiss()
                }
                
            } catch {
                await MainActor.run {
                    print("❌ API Hatası: \(error)")
                    errorMessage = "Kaydetme hatası: \(error.localizedDescription)"
                    showError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func deleteImage(carId: String, imageId: String) async throws {
        let url = URL(string: "http://localhost:8080/cars/\(carId)/images/\(imageId)")!
        print("🔗 Delete URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Auth headers ekle
        let headers = authService.getAuthHeaders()
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        print("🔐 Auth Headers: \(headers)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Delete Status: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Delete Error: \(responseString)")
                }
                throw URLError(.badServerResponse)
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Delete Response: \(responseString)")
            }
        }
        
        print("✅ Fotoğraf başarıyla silindi: \(imageId)")
    }
    
    private func uploadImages(carId: String, images: [UIImage]) async throws {
        let boundary = UUID().uuidString
        let url: URL
        var request: URLRequest
        
        if images.count == 1 {
            // Tek fotoğraf için normal endpoint
            url = URL(string: "http://localhost:8080/cars/\(carId)/images")!
            print("📡 Tek fotoğraf endpoint: \(url)")
        } else {
            // Birden fazla fotoğraf için batch endpoint
            url = URL(string: "http://localhost:8080/cars/\(carId)/images/batch")!
            print("📡 Batch fotoğraf endpoint: \(url)")
        }
        
        request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Auth headers ekle (Content-Type'ı ezmemek için sadece Authorization'ı al)
        if let token = authService.getTokenFromStorage() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 Authorization Header eklendi: Bearer \(token.prefix(20))...")
        } else {
            print("⚠️ Auth token bulunamadı!")
        }
        
        var body = Data()
        
        for (index, image) in images.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { 
                print("⚠️ Fotoğraf \(index) JPEG'e çevrilemedi")
                continue 
            }
            
            let fileSizeKB = Double(imageData.count) / 1024.0
            let fileSizeMB = fileSizeKB / 1024.0
            
            let fieldName = images.count == 1 ? "file" : "files"
            let fileName = "image_\(index).jpg"
            
            print("📎 Ekleniyor: \(fieldName) = \(fileName)")
            print("📏 Dosya boyutu: \(imageData.count) bytes (\(String(format: "%.1f", fileSizeKB)) KB / \(String(format: "%.2f", fileSizeMB)) MB)")
            
            // Çok büyükse uyarı ver
            if imageData.count > 2 * 1024 * 1024 { // 2MB
                print("⚠️ UYARI: Dosya 2MB'dan büyük! Server reddedebilir.")
            }
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let totalSizeKB = Double(body.count) / 1024.0
        let totalSizeMB = totalSizeKB / 1024.0
        
        print("📤 İstek gönderiliyor:")
        print("📏 Toplam boyut: \(body.count) bytes (\(String(format: "%.1f", totalSizeKB)) KB / \(String(format: "%.2f", totalSizeMB)) MB)")
        
        // Server limit kontrolü
        if body.count > 10 * 1024 * 1024 { // 10MB
            print("🚨 HATA: Request 10MB'dan büyük! Server kesinlikle reddedecek.")
        } else if body.count > 5 * 1024 * 1024 { // 5MB
            print("⚠️ UYARI: Request 5MB'dan büyük! Server reddedebilir.")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ Error Response: \(responseString)")
                }
                throw URLError(.badServerResponse)
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Success Response: \(responseString)")
            }
        }
        
        print("✅ \(images.count) fotoğraf başarıyla yüklendi")
    }
} 