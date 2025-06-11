import Foundation
import CoreLocation
import MapKit

// MARK: - CLLocationCoordinate2D Equatable Extension
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentAddress: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Kullanıcıyı ayarlara yönlendir
            DispatchQueue.main.async {
                self.errorMessage = "Konum izni ayarlardan açılmalıdır"
            }
        case .authorizedWhenInUse, .authorizedAlways:
            getCurrentLocation()
        @unknown default:
            break
        }
    }
    
    func getCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        isLoading = true
        errorMessage = nil
        locationManager.requestLocation()
    }
    
    private func reverseGeocodeLocation(_ location: CLLocationCoordinate2D) {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Adres bulunamadı: \(error.localizedDescription)"
                    return
                }
                
                if let placemark = placemarks?.first {
                    self?.formatAddress(from: placemark)
                }
            }
        }
    }
    
    private func formatAddress(from placemark: CLPlacemark) {
        var addressComponents: [String] = []
        
        if let thoroughfare = placemark.thoroughfare {
            if let subThoroughfare = placemark.subThoroughfare {
                addressComponents.append("\(thoroughfare) No:\(subThoroughfare)")
            } else {
                addressComponents.append(thoroughfare)
            }
        }
        
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        currentAddress = addressComponents.joined(separator: ", ")
        print("🏠 Formatted address: \(currentAddress)")
    }
    
    // MARK: - Public Methods for Address Retrieval
    
    func getAddressFromLocation(_ location: CLLocation) async -> String? {
        return await withCheckedContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("❌ Reverse geocoding error: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("❌ No placemark found")
                    continuation.resume(returning: nil)
                    return
                }
                
                let formattedAddress = self.formatAddressFromPlacemark(placemark)
                print("🏠 Reverse geocoded address: \(formattedAddress)")
                continuation.resume(returning: formattedAddress)
            }
        }
    }
    
    private func formatAddressFromPlacemark(_ placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare,
           let thoroughfare = placemark.thoroughfare {
            addressComponents.append("\(subThoroughfare), \(thoroughfare)")
        } else if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        if let subAdministrativeArea = placemark.subAdministrativeArea {
            addressComponents.append(subAdministrativeArea)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            self.reverseGeocodeLocation(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = "Konum alınamadı: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }
} 