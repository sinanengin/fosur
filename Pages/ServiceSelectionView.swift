import SwiftUI

struct ServiceSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedServices: Set<Service>
    let services: [Service] // API'den gelen gerçek hizmet verileri
    @State private var searchText = ""
    
    private var filteredServices: [Service] {
        if searchText.isEmpty {
            return services
        } else {
            return services.filter { service in
                service.title.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var totalPrice: Double {
        selectedServices.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Arama Barı
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                        
                        TextField("Hizmet ara...", text: $searchText)
                            .font(CustomFont.regular(size: 16))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Hizmet Grid'i
                ScrollView {
                    if services.isEmpty {
                        // Loading veya boş durum
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.logo)
                            
                            Text("Hizmetler yükleniyor...")
                                .font(CustomFont.medium(size: 18))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else if filteredServices.isEmpty && !searchText.isEmpty {
                        // Arama sonucu bulunamadı
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Böyle bir hizmet bulunamadı")
                                .font(CustomFont.medium(size: 18))
                                .foregroundColor(.gray)
                            
                            Text("Arama terimlerinizi kontrol edin")
                                .font(CustomFont.regular(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 100)
                    } else {
                        // Hizmet Kartları Grid'i
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 12) {
                            ForEach(filteredServices) { service in
                                ServiceGridCard(
                                    service: service,
                                    isSelected: selectedServices.contains(service),
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            if selectedServices.contains(service) {
                                                selectedServices.remove(service)
                                            } else {
                                                selectedServices.insert(service)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                
                // Toplam Ücret ve Devam Et Butonu
                VStack(spacing: 0) {
                    // Seçilen Hizmetler Özeti
                    if !selectedServices.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(selectedServices.count) hizmet seçildi")
                                    .font(CustomFont.medium(size: 14))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("Toplam Tutar")
                                    .font(CustomFont.medium(size: 16))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(String(format: "%.2f ₺", totalPrice))
                                    .font(CustomFont.bold(size: 20))
                                    .foregroundColor(.logo)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    
                    // Devam Et Butonu
                    Button(action: {
                        dismiss()
                    }) {
                        Text(selectedServices.isEmpty ? "Hizmet Seçin" : "Devam Et")
                            .font(CustomFont.bold(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedServices.isEmpty ? Color.gray.opacity(0.4) : Color.logo)
                            .cornerRadius(12)
                            .shadow(color: selectedServices.isEmpty ? Color.clear : Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(selectedServices.isEmpty)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
            }
            .background(Color("BackgroundColor"))
            .navigationTitle("Hizmet Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct ServiceGridCard: View {
    let service: Service
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Hizmet Görseli - Sabit boyut, daha aşağıda ve yuvarlak köşeler
            serviceImageView
                .frame(width: 90, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.top, 16)
            
            // İçerik Alanı - Sabit boyut
            VStack(spacing: 4) {
                // Hizmet Başlığı - Sabit yükseklik
                Text(service.title)
                    .font(CustomFont.bold(size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 32)
                
                // Hizmet Açıklaması - Sabit yükseklik
                Text(service.description)
                    .font(CustomFont.regular(size: 10))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 28)
                
                Spacer()
                
                // Fiyat - Sabit yükseklik
                Text(String(format: "%.2f ₺", service.price))
                    .font(CustomFont.bold(size: 13))
                    .foregroundColor(.logo)
                    .frame(height: 20)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .frame(width: 110, height: 170) // Sabit kart boyutu
        .background(
            ZStack {
                // Ana arka plan
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                
                // Seçili parıldama efekti - alttan çıkar
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.logo.opacity(0.3),
                                    Color.logo.opacity(0.1),
                                    Color.clear
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .animation(.easeInOut(duration: 0.3), value: isSelected)
                }
                
                // Seçili çerçeve
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.logo : Color.clear, lineWidth: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // Basma animasyonu
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            // Seçim işlevi
            onTap()
            
            // Animasyonu sıfırla
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
    
    @ViewBuilder
    private var serviceImageView: some View {
        if let imageUrl = service.images.first, !imageUrl.isEmpty {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.logo)
            }
        } else {
            // Varsayılan ikon
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 28))
                .foregroundColor(.logo)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    ServiceSelectionView(
        selectedServices: .constant([]),
        services: []
    )
} 