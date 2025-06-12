import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) var dismiss
    let order: Order
    let onOrderUpdated: (() -> Void)?
    let onDismiss: (() -> Void)?
    @State private var showCancelAlert = false
    @State private var showActionsMenu = false
    @State private var isUpdating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var vehicle: Vehicle?
    @State private var isLoadingVehicle = true
    @State private var services: [ServiceData] = []
    @State private var isLoadingServices = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Progress Bar
                    statusProgressBar
                    
                    // Order Info Card
                    orderInfoCard
                    
                    // Address Card
                    addressCard
                    
                    // Vehicle Card
                    vehicleCard
                    
                    // Services Card
                    servicesCard
                    
                    // Price Card
                    if let totalPrice = order.totalPrice {
                        priceCard(totalPrice: totalPrice)
                    }
                    
                    // Bottom spacing
                    Color.clear.frame(height: 20)
                }
                .padding()
            }
            .navigationTitle("Sipariş Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if let onDismiss = onDismiss {
                            onDismiss()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showActionsMenu = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .confirmationDialog("Sipariş İşlemleri", isPresented: $showActionsMenu) {
                if order.state != .canceled && order.state != .completed {
                    Button("Siparişi İptal Et", role: .destructive) {
                        showCancelAlert = true
                    }
                }
                Button("İptal", role: .cancel) { }
            }
            .alert("Siparişi İptal Et", isPresented: $showCancelAlert) {
                Button("İptal", role: .cancel) { }
                Button("Evet, İptal Et", role: .destructive) {
                    cancelOrder()
                }
            } message: {
                Text("Bu siparişi iptal etmek istediğinizden emin misiniz?")
            }
            .alert("Başarılı", isPresented: $showSuccess) {
                Button("Tamam") {
                    if let onDismiss = onDismiss {
                        onDismiss()
                    } else {
                        dismiss()
                    }
                }
            } message: {
                Text(successMessage)
            }
            .alert("Hata", isPresented: $showError) {
                Button("Tamam") { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isUpdating {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("İşleniyor...")
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private var statusProgressBar: some View {
        VStack(spacing: 16) {
            // Current Status
            HStack {
                StatusBadge(state: order.state)
                Spacer()
            }
            
            // Progress Steps - sadece belirli state'ler
            let progressStates: [OrderState] = [.approved, .assigned, .washed, .completed]
            
            HStack(spacing: 0) {
                ForEach(Array(progressStates.enumerated()), id: \.offset) { index, state in
                    HStack(spacing: 0) {
                        // Step Circle
                        Circle()
                            .fill(stepColor(for: state))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                        
                        // Line to next step
                        if index < progressStates.count - 1 {
                            Rectangle()
                                .fill(lineColor(for: state))
                                .frame(height: 2)
                        }
                    }
                }
            }
            
            // Step Labels
            HStack {
                ForEach(progressStates, id: \.self) { state in
                    Text(state.displayName)
                        .font(CustomFont.regular(size: 10))
                        .foregroundColor(stepColor(for: state))
                        .frame(maxWidth: .infinity)
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
    
    private var orderInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Sipariş Bilgileri")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                infoRow(title: "Sipariş ID", value: String(order.id.suffix(8)))
                infoRow(title: "Rezervasyon Tarihi", value: formatDate(order.reservationTime))
                if let createdAt = order.createdAt {
                    infoRow(title: "Sipariş Tarihi", value: formatDate(createdAt))
                }
                infoRow(title: "Durum", value: order.state.displayName)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
    
    private var addressCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                Text("Hizmet Adresi")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(order.address.name)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Text(order.address.formattedAddress)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
    
    private var vehicleCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "car.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                Text("Araç Bilgileri")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Araç görseli
                if let vehicle = vehicle, !vehicle.images.isEmpty {
                    AsyncImage(url: URL(string: vehicle.images.first?.url ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "car.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.logo)
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.logo.opacity(0.1))
                    .clipShape(Circle())
                } else {
                    Image(systemName: "car.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.logo)
                        .frame(width: 60, height: 60)
                        .background(Color.logo.opacity(0.1))
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let vehicle = vehicle {
                        Text("\(vehicle.brand) \(vehicle.model)")
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.primary)
                        
                        Text(vehicle.plate)
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                    } else if isLoadingVehicle {
                        Text("Araç bilgileri yükleniyor...")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                    } else {
                        Text("Araç bilgisi bulunamadı")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            loadVehicleDetails()
        }
    }
    
    private var servicesCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                Text("Seçilen Hizmetler")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                if isLoadingServices {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Hizmetler yükleniyor...")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if services.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                        
                        Text("Hizmet bilgileri bulunamadı")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                } else {
                    ForEach(services, id: \.id) { service in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(service.name)
                                    .font(CustomFont.medium(size: 14))
                                    .foregroundColor(.primary)
                                
                                Text(service.details)
                                    .font(CustomFont.regular(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Text("₺\(String(format: "%.2f", service.price))")
                                .font(CustomFont.bold(size: 14))
                                .foregroundColor(.logo)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            loadServiceDetails()
        }
    }
    
    private func priceCard(totalPrice: Double) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                Text("Ödeme Bilgileri")
                    .font(CustomFont.bold(size: 18))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Toplam Tutar")
                        .font(CustomFont.regular(size: 16))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("₺\(String(format: "%.2f", totalPrice))")
                        .font(CustomFont.bold(size: 18))
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
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(CustomFont.medium(size: 14))
                .foregroundColor(.primary)
        }
    }
    
    private func stepColor(for state: OrderState) -> Color {
        let progressStates: [OrderState] = [.approved, .assigned, .washed, .completed]
        
        guard let currentStateIndex = progressStates.firstIndex(of: order.state),
              let stateIndex = progressStates.firstIndex(of: state) else {
            return .gray.opacity(0.3)
        }
        
        if order.state == .canceled {
            return .red
        }
        
        return stateIndex <= currentStateIndex ? .logo : .gray.opacity(0.3)
    }
    
    private func lineColor(for state: OrderState) -> Color {
        let progressStates: [OrderState] = [.approved, .assigned, .washed, .completed]
        
        guard let currentStateIndex = progressStates.firstIndex(of: order.state),
              let stateIndex = progressStates.firstIndex(of: state) else {
            return .gray.opacity(0.3)
        }
        
        if order.state == .canceled {
            return .gray.opacity(0.3)
        }
        
        return stateIndex < currentStateIndex ? .logo : .gray.opacity(0.3)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
            displayFormatter.locale = Locale(identifier: "tr_TR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
    
    private func cancelOrder() {
        Task {
            await MainActor.run {
                isUpdating = true
            }
            
            do {
                let _ = try await OrderService.shared.updateOrderState(
                    orderId: order.id,
                    newState: .canceled
                )
                
                await MainActor.run {
                    isUpdating = false
                    successMessage = "Sipariş başarıyla iptal edildi"
                    showSuccess = true
                    onOrderUpdated?()
                }
            } catch {
                await MainActor.run {
                    isUpdating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func loadVehicleDetails() {
        Task {
            do {
                vehicle = try await VehicleService.shared.getVehicleDetails(car: order.car)
                await MainActor.run {
                    isLoadingVehicle = false
                }
            } catch {
                await MainActor.run {
                    isLoadingVehicle = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func loadServiceDetails() {
        Task {
            do {
                var loadedServices: [ServiceData] = []
                
                // Her washPackage ID'si için hizmet detaylarını al
                for packageId in order.washPackages {
                    if let service = try await ServicesService.shared.getServiceById(packageId) {
                        loadedServices.append(service)
                    }
                }
                
                await MainActor.run {
                    services = loadedServices
                    isLoadingServices = false
                }
                
                print("✅ \(loadedServices.count) hizmet detayı yüklendi")
            } catch {
                await MainActor.run {
                    isLoadingServices = false
                    print("❌ Hizmet detayları yüklenirken hata: \(error)")
                }
            }
        }
    }
}

#Preview {
    OrderDetailView(
        order: Order(
            id: "preview123",
            address: OrderAddress(
                id: "addr123",
                name: "Test Address",
                formattedAddress: "Test Street 123, Test City",
                latitude: 41.0369,
                longitude: 28.9855,
                street: "Test Street",
                neighborhood: "Test Neighborhood",
                district: "Test District", 
                city: "Test City",
                province: "Test Province",
                postalCode: "34000",
                country: "Türkiye"
            ),
            car: "car123",
            reservationTime: "2025-06-09T10:00:00Z",
            washPackages: ["wash123"],
            owner: "customer123",
            state: .approved,
            createdAt: "2025-06-09T09:00:00Z",
            updatedAt: "2025-06-09T09:00:00Z",
            totalPrice: 150.0
        ),
        onOrderUpdated: nil,
        onDismiss: nil
    )
} 
