import SwiftUI
import MapKit
import CoreLocation

struct AddressDetailView: View {
    @Environment(\.dismiss) var dismiss
    let address: Address
    let onAddressUpdated: (() -> Void)?
    let onDismiss: (() -> Void)?
    @State private var addressName: String
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var region: MKCoordinateRegion
    @State private var currentFormattedAddress: String
    @State private var isUpdating = false
    @State private var isDeleting = false
    @State private var showDeleteAlert = false
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    init(address: Address, onAddressUpdated: (() -> Void)? = nil, onDismiss: (() -> Void)? = nil) {
        self.address = address
        self.onAddressUpdated = onAddressUpdated
        self.onDismiss = onDismiss
        self._addressName = State(initialValue: address.title)
        self._selectedCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude))
        self._currentFormattedAddress = State(initialValue: address.fullAddress)
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Scrollable Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Map Section
                        mapSection
                        
                        // Search Section
                        searchSection
                        
                        // Address Info Section
                        addressInfoSection
                        
                        // Bottom spacing
                        Color.clear
                            .frame(height: 20)
                    }
                }
                
                // Action Buttons (Fixed at bottom)
                actionButtonsSection
            }
            .navigationTitle("Adres Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss?()  // Parent'a bildir
                        dismiss()     // Sheet'i kapat
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .alert("Adresi Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                Task {
                    await deleteAddress()
                }
            }
        } message: {
            Text("Bu adresi silmek istediğinizden emin misiniz?")
        }
        .alert(successMessage, isPresented: $showSuccessMessage) {
            Button("Tamam") {
                onDismiss?()  // Parent'a bildir
                dismiss()     // Sheet'i kapat
            }
        }
        .alert("Hata", isPresented: $showErrorMessage) {
            Button("Tamam") { }
        } message: {
            Text(errorMessage)
        }
    }
    

    
    @ViewBuilder
    private var mapSection: some View {
        VStack(spacing: 0) {
            Map(position: .constant(MapCameraPosition.region(region))) {
                Annotation("", coordinate: selectedCoordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
            .frame(height: 200)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // Pinch ve pan gesture desteği
                    }
            )
            .onTapGesture { location in
                withAnimation(.easeInOut(duration: 0.3)) {
                    let coordinate = convert(location, from: UIScreen.main.bounds, to: region)
                    selectedCoordinate = coordinate
                    region.center = coordinate
                    
                    // Update formatted address when map is tapped
                    updateFormattedAddressFromCoordinate(coordinate)
                }
            }
        }
    }
    
    @ViewBuilder
    private var searchSection: some View {
        VStack(spacing: 0) {
            searchBar
            searchResultsList
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Adres ara...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: searchText) { _, newValue in
                    searchAddress(query: newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
    
    @ViewBuilder
    private var searchResultsList: some View {
        if isSearching {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Aranıyor...")
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
        } else if !searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Arama Sonuçları (\(searchResults.count))")
                    .font(CustomFont.medium(size: 14))
                    .foregroundColor(.logo)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(searchResults, id: \.self) { result in
                            Button(action: {
                                print("🎯 Seçilen: \(result.name ?? "İsimsiz")")
                                selectSearchResult(result)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.name ?? "İsimsiz Konum")
                                        .font(CustomFont.medium(size: 16))
                                        .foregroundColor(.primary)
                                    
                                    Text(result.placemark.title ?? "Detay yok")
                                        .font(CustomFont.regular(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.white)
                            }
                            
                            if result != searchResults.last {
                                Divider()
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .frame(maxHeight: 200)
            }
            .padding(.horizontal)
        } else if !searchText.isEmpty {
            Text("Sonuç bulunamadı")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    @ViewBuilder
    private var addressInfoSection: some View {
        VStack(spacing: 16) {
            // Address Name Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Adres Adı")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                TextField("Ev, İş, Anne Evi...", text: $addressName)
                    .font(CustomFont.regular(size: 16))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            // Current Address Display
            VStack(alignment: .leading, spacing: 8) {
                Text("Mevcut Adres")
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Text(currentFormattedAddress)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                    )
            }
            
            // New Coordinates Info (if changed)
            if hasLocationChanged {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Yeni Konum")
                        .font(CustomFont.medium(size: 16))
                        .foregroundColor(.logo)
                    
                    Text("Latitude: \(selectedCoordinate.latitude, specifier: "%.6f")")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("Longitude: \(selectedCoordinate.longitude, specifier: "%.6f")")
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.logo.opacity(0.05))
                )
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Delete Button (Sol taraf)
            Button(action: {
                showDeleteAlert = true
            }) {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("Adresi Sil")
                            .font(CustomFont.bold(size: 16))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.7, green: 0.1, blue: 0.1))
                .cornerRadius(12)
                .shadow(color: Color(red: 0.7, green: 0.1, blue: 0.1).opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isDeleting || isUpdating)
            
            // Update Button (Sağ taraf)
            Button(action: {
                Task {
                    await updateAddress()
                }
            }) {
                HStack {
                    if isUpdating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Text("Güncelle")
                            .font(CustomFont.bold(size: 16))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(hasChanges ? Color.logo : Color.gray.opacity(0.4))
                .cornerRadius(12)
                .shadow(color: hasChanges ? Color.logo.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            }
            .disabled(!hasChanges || isUpdating)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private var hasChanges: Bool {
        addressName != address.title || hasLocationChanged || currentFormattedAddress != address.fullAddress
    }
    
    private var hasLocationChanged: Bool {
        abs(selectedCoordinate.latitude - address.latitude) > 0.0001 ||
        abs(selectedCoordinate.longitude - address.longitude) > 0.0001
    }
    
    private func convert(_ location: CGPoint, from bounds: CGRect, to region: MKCoordinateRegion) -> CLLocationCoordinate2D {
        let relativeX = location.x / bounds.width
        let relativeY = location.y / bounds.height
        
        let latitude = region.center.latitude + (relativeY - 0.5) * region.span.latitudeDelta
        let longitude = region.center.longitude + (relativeX - 0.5) * region.span.longitudeDelta
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private func updateAddress() async {
        isUpdating = true
        
        do {
            // Use current formatted address (updated by search or map tap)
            let _ = try await CustomerService.shared.updateAddress(
                addressId: address.id,
                name: addressName,
                formattedAddress: currentFormattedAddress,
                latitude: selectedCoordinate.latitude,
                longitude: selectedCoordinate.longitude,
                street: "",
                neighborhood: "",
                district: "",
                city: "",
                province: "",
                postalCode: "",
                country: "Türkiye"
            )
            
            await MainActor.run {
                isUpdating = false
                successMessage = "Adresiniz başarıyla güncellendi"
                showSuccessMessage = true
                onAddressUpdated?() // Refresh callback
            }
            
        } catch {
            await MainActor.run {
                isUpdating = false
                errorMessage = error.localizedDescription
                showErrorMessage = true
            }
        }
    }
    
    private func deleteAddress() async {
        isDeleting = true
        
        do {
            try await CustomerService.shared.deleteAddress(addressId: address.id)
            
            await MainActor.run {
                isDeleting = false
                successMessage = "Adres başarıyla silindi"
                showSuccessMessage = true
                onAddressUpdated?() // Refresh callback
            }
            
        } catch {
            await MainActor.run {
                isDeleting = false
                errorMessage = error.localizedDescription
                showErrorMessage = true
            }
        }
    }
    
    // MARK: - Search Functions
    
    private func searchAddress(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            isSearching = false
            print("🔍 Arama temizlendi")
            return
        }
        
        print("🔍 Arama yapılıyor: \(query)")
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            DispatchQueue.main.async {
                self.isSearching = false
                
                if let error = error {
                    print("❌ Arama hatası: \(error.localizedDescription)")
                    return
                }
                
                let results = response?.mapItems ?? []
                self.searchResults = results
                print("✅ Arama sonucu: \(results.count) sonuç bulundu")
                
                // İlk birkaç sonucu logla
                for (index, result) in results.prefix(3).enumerated() {
                    print("  \(index + 1). \(result.name ?? "İsimsiz") - \(result.placemark.title ?? "")")
                }
            }
        }
    }
    
    private func selectSearchResult(_ result: MKMapItem) {
        let coordinate = result.placemark.coordinate
        print("📍 Seçilen konum: \(coordinate.latitude), \(coordinate.longitude)")
        
        withAnimation(.easeInOut(duration: 0.5)) {
            selectedCoordinate = coordinate
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        // Update formatted address from selected result
        updateFormattedAddressFromCoordinate(coordinate)
        
        // Clear search results and set search text to selected place name
        searchText = result.name ?? ""
        searchResults = []
        print("✅ Arama temizlendi, seçilen: \(searchText)")
    }
    
    private func updateFormattedAddressFromCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Geocoding hatası: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let addressComponents = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.subLocality,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.postalCode,
                        placemark.country
                    ].compactMap { $0 }
                    
                    self.currentFormattedAddress = addressComponents.joined(separator: ", ")
                }
            }
        }
    }
}

#Preview {
    AddressDetailView(address: Address(
        id: "1",
        title: "Ev",
        fullAddress: "21, Serbest Sk., Sefaköy, Küçükçekmece, İstanbul, 34295, Türkiye",
        latitude: 41.00060776014588,
        longitude: 28.78551492234334
    ))
} 