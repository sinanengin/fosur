import SwiftUI

struct ServiceSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedServices: Set<Service>
    let services: [Service]
    @State private var selectedCategory: ServiceCategory?
    
    private var filteredServices: [Service] {
        if let category = selectedCategory {
            return services.filter { $0.category == category }
        }
        return services
    }
    
    private var totalPrice: Double {
        selectedServices.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Kategori Seçimi
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryButton(
                            title: "Tümü",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(ServiceCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                // Hizmet Listesi
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredServices) { service in
                            ServiceRow(
                                service: service,
                                isSelected: selectedServices.contains(service)
                            )
                            .onTapGesture {
                                if selectedServices.contains(service) {
                                    selectedServices.remove(service)
                                } else {
                                    selectedServices.insert(service)
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Toplam Ücret ve Tamam Butonu
                VStack(spacing: 16) {
                    HStack {
                        Text("Toplam Tutar")
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(String(format: "%.2f ₺", totalPrice))
                            .font(CustomFont.bold(size: 20))
                            .foregroundColor(.logo)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Tamam")
                            .font(CustomFont.bold(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.logo)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
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

struct ServiceRow: View {
    let service: Service
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 24))
                .foregroundColor(.logo)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(service.title)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Text(service.description)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f ₺", service.price))
                    .font(CustomFont.bold(size: 16))
                    .foregroundColor(.logo)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.logo)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}

#Preview {
    ServiceSelectionView(
        selectedServices: .constant([]),
        services: []
    )
} 