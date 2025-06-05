import SwiftUI
import MapKit

struct AddAddressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var addressTitle = ""
    @State private var fullAddress = ""
    @State private var selectedCoordinates: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedAddressType: AddressType = .home
    @State private var showLocationPermissionAlert = false
    @State private var locationManager = CLLocationManager()
    
    let onAddressAdded: (Address) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Harita
                Map {
                    if let coordinate = selectedCoordinates {
                        Marker("Seçilen Konum", coordinate: coordinate)
                            .tint(.logo)
                    }
                }
                .frame(height: 300)
                .overlay(
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.logo)
                        .shadow(radius: 2)
                )
                .onTapGesture { location in
                    let coordinate = region.center
                    selectedCoordinates = coordinate
                    updateAddressFromCoordinate(coordinate)
                }
                
                // Arama Çubuğu
                VStack(spacing: 0) {
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
                    
                    if isSearching {
                        ProgressView()
                            .padding()
                    } else if !searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults, id: \.self) { result in
                                    Button(action: {
                                        selectSearchResult(result)
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.name ?? "")
                                                .font(CustomFont.medium(size: 16))
                                                .foregroundColor(.primary)
                                            
                                            Text(result.placemark.title ?? "")
                                                .font(CustomFont.regular(size: 14))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
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
                        .padding(.horizontal)
                    }
                }
                
                // Adres Formu
                ScrollView {
                    VStack(spacing: 20) {
                        // Adres Başlığı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adres Başlığı")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            TextField("Örn: Ev, İş, Anne Evi", text: $addressTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Adres Tipi
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adres Tipi")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(AddressType.allCases, id: \.self) { type in
                                    AddressTypeButton(
                                        type: type,
                                        isSelected: selectedAddressType == type,
                                        action: { selectedAddressType = type }
                                    )
                                }
                            }
                        }
                        
                        // Adres Detayı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Adres Detayı")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $fullAddress)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Konum Bilgisi
                        if let coordinate = selectedCoordinates {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Konum Bilgisi")
                                    .font(CustomFont.medium(size: 16))
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.logo)
                                    
                                    Text("\(coordinate.latitude), \(coordinate.longitude)")
                                        .font(CustomFont.regular(size: 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Yeni Adres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveAddress()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Konum İzni Gerekli", isPresented: $showLocationPermissionAlert) {
                Button("Ayarlara Git") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("İptal", role: .cancel) { }
            } message: {
                Text("Adres eklemek için konum izni gereklidir. Lütfen ayarlardan konum iznini etkinleştirin.")
            }
            .onAppear {
                checkLocationPermission()
            }
        }
    }
    
    private var isFormValid: Bool {
        !addressTitle.isEmpty && !fullAddress.isEmpty && selectedCoordinates != nil
    }
    
    private func checkLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationPermissionAlert = true
        default:
            break
        }
    }
    
    private func searchAddress(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            if let error = error {
                print("Arama hatası: \(error.localizedDescription)")
                return
            }
            
            searchResults = response?.mapItems ?? []
        }
    }
    
    private func selectSearchResult(_ result: MKMapItem) {
        let coordinate = result.placemark.coordinate
        selectedCoordinates = coordinate
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        updateAddressFromCoordinate(coordinate)
        searchText = result.name ?? ""
        searchResults = []
    }
    
    private func updateAddressFromCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding hatası: \(error.localizedDescription)")
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
                
                fullAddress = addressComponents.joined(separator: ", ")
            }
        }
    }
    
    private func saveAddress() {
        guard let coordinate = selectedCoordinates else { return }
        
        let address = Address(
            id: UUID().uuidString,
            title: addressTitle,
            fullAddress: fullAddress,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        onAddressAdded(address)
        dismiss()
    }
}

struct AddressTypeButton: View {
    let type: AddressType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                Text(type.title)
            }
            .font(CustomFont.medium(size: 14))
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.logo : Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

enum AddressType: String, CaseIterable {
    case home
    case work
    case other
    
    var title: String {
        switch self {
        case .home: return "Ev"
        case .work: return "İş"
        case .other: return "Diğer"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "briefcase.fill"
        case .other: return "mappin.circle.fill"
        }
    }
}

#Preview {
    AddAddressView { _ in }
} 