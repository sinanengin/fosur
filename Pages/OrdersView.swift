import SwiftUI

struct OrdersView: View {
    @Environment(\.dismiss) var dismiss
    @State private var orders: [Order] = []
    @State private var allOrders: [Order] = [] // Tüm siparişler (filtrelenmemiş)
    @State private var isLoading = false
    @State private var selectedFilter: OrderState? = nil
    @State private var selectedOrder: Order? = nil
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Progress bar'daki 4 ana duruma göre kategoriler + Tümü + İptal Edildi
    private let filterStates: [OrderState?] = [
        nil,                    // Tümü
        .approved,             // Onaylandı
        .assigned,             // Atandı  
        .washed,               // Yıkandı
        .completed,            // Tamamlandı
        .canceled              // İptal Edildi
    ]
    
    // Filtre için özel isimler
    private func getFilterDisplayName(for state: OrderState?) -> String {
        switch state {
        case nil: return "Tümü"
        case .approved, .approvedLower: return "Onaylandı"
        case .assigned, .assignedLower: return "Atandı"
        case .washed, .washedLower: return "Yıkandı"  
        case .completed, .completedLower: return "Tamamlandı"
        case .canceled, .canceledLower: return "İptal Edildi"
        default: return state?.displayName ?? "Bilinmeyen"
        }
    }
    
    // Filtre renkleri
    private func getFilterColor(for state: OrderState?) -> Color {
        switch state {
        case nil: return Color.logo                    // Tümü - Ana marka rengi
        case .approved, .approvedLower: return .blue   // Onaylandı - Mavi
        case .assigned, .assignedLower: return .purple // Atandı - Mor
        case .washed, .washedLower: return .green      // Yıkandı - Yeşil
        case .completed, .completedLower: return .green // Tamamlandı - Yeşil
        case .canceled, .canceledLower: return .red    // İptal Edildi - Kırmızı
        default: return .gray
        }
    }
    
    // Filtre kategorilerindeki sipariş sayılarını hesapla
    private func getOrderCount(for filterState: OrderState?) -> Int {
        if filterState == nil {
            return allOrders.count // Tümü
        }
        
        return allOrders.filter { order in
            matchesFilterState(order.state, filter: filterState!)
        }.count
    }
    
    // Filtre başlığı + sayı
    private func getFilterTitleWithCount(for state: OrderState?) -> String {
        let title = getFilterDisplayName(for: state)
        let count = getOrderCount(for: state)
        return "\(title) (\(count))"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Bar
                filterBar
                
                // Orders List
                if isLoading {
                    loadingView
                } else if orders.isEmpty {
                    emptyStateView
                } else {
                    ordersList
                }
            }
            .navigationTitle("Siparişlerim")
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
        .sheet(isPresented: .constant(selectedOrder != nil), onDismiss: {
            selectedOrder = nil
        }) {
            if let order = selectedOrder {
                OrderDetailView(
                    order: order,
                    onOrderUpdated: {
                        loadOrders()
                    },
                    onDismiss: {
                        selectedOrder = nil
                    }
                )
            }
        }
        .alert("Hata", isPresented: $showError) {
            Button("Tamam") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadOrders()
        }
        .background(Color("BackgroundColor"))
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(filterStates.enumerated()), id: \.offset) { index, state in
                    FilterChip(
                        title: getFilterTitleWithCount(for: state),
                        isSelected: selectedFilter == state,
                        filterState: state,
                        getFilterColor: getFilterColor,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedFilter = state
                                loadOrders()
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Siparişler yükleniyor...")
                .font(CustomFont.regular(size: 16))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Henüz sipariş vermemişsiniz")
                .font(CustomFont.medium(size: 18))
                .foregroundColor(.primary)
            
            Text("İlk siparişinizi vermek için Ana Sayfa'ya gidin")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
    }
    
    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(orders) { order in
                    OrderRow(
                        order: order,
                        onTap: {
                            selectedOrder = order
                        }
                    )
                }
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
        .refreshable {
            loadOrders()
        }
    }
    
    private func loadOrders() {
        guard let customerId = AuthService.shared.getCurrentCustomerId() else {
            errorMessage = "Kullanıcı bilgisi bulunamadı"
            showError = true
            return
        }
        
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                // Tüm siparişleri al
                let fetchedOrders = try await OrderService.shared.getOrders(
                    customerId: customerId,
                    state: nil
                )
                
                // Client-side filtering
                let filteredOrders: [Order]
                if let selectedFilter = selectedFilter {
                    filteredOrders = fetchedOrders.filter { order in
                        // Hem uppercase hem lowercase versiyonlarını kontrol et
                        return matchesFilterState(order.state, filter: selectedFilter)
                    }
                } else {
                    filteredOrders = fetchedOrders
                }
                
                await MainActor.run {
                    self.orders = filteredOrders.sorted { 
                        // En yeni siparişler üstte
                        ($0.createdAt ?? "") > ($1.createdAt ?? "")
                    }
                    self.allOrders = fetchedOrders // Tüm siparişleri sakla
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
    
    // State matching fonksiyonu - hem uppercase hem lowercase versiyonları destekler
    private func matchesFilterState(_ orderState: OrderState, filter: OrderState) -> Bool {
        switch filter {
        case .approved:
            return orderState == .approved || orderState == .approvedLower
        case .assigned:
            return orderState == .assigned || orderState == .assignedLower
        case .washed:
            return orderState == .washed || orderState == .washedLower
        case .completed:
            return orderState == .completed || orderState == .completedLower
        case .canceled:
            return orderState == .canceled || orderState == .canceledLower
        default:
            return orderState == filter
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let filterState: OrderState?
    let getFilterColor: (OrderState?) -> Color
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            Text(title)
                .font(CustomFont.medium(size: 14))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? getFilterColor(filterState) : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

struct OrderRow: View {
    let order: Order
    let onTap: () -> Void
    @State private var isPressed = false
    @State private var vehicle: Vehicle?
    @State private var isLoadingVehicle = true
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 12) {
                // Status ve Tarih
                HStack {
                    StatusBadge(state: order.state)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatDate(order.reservationTime))
                            .font(CustomFont.medium(size: 14))
                            .foregroundColor(.primary)
                        if let createdAt = order.createdAt {
                            Text("Sipariş: \(formatDate(createdAt))")
                                .font(CustomFont.regular(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Araç ve Adres Bilgisi
                HStack(spacing: 12) {
                    // Araç görseli
                    if let vehicle = vehicle, !vehicle.images.isEmpty {
                        AsyncImage(url: URL(string: vehicle.images.first?.url ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "car.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.logo)
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.logo.opacity(0.1))
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "car.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.logo)
                            .frame(width: 40, height: 40)
                            .background(Color.logo.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Araç bilgisi
                        if let vehicle = vehicle {
                            Text("\(vehicle.brand) \(vehicle.model)")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                            
                            Text(vehicle.plate)
                                .font(CustomFont.regular(size: 12))
                                .foregroundColor(.secondary)
                        } else if isLoadingVehicle {
                            Text("Araç bilgisi yükleniyor...")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                        } else {
                            Text("Araç bilgisi")
                                .font(CustomFont.medium(size: 16))
                                .foregroundColor(.primary)
                        }
                        
                        // Adres bilgisi
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.logo)
                            
                            Text(order.address.name)
                                .font(CustomFont.regular(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                
                // Toplam Fiyat
                if let totalPrice = order.totalPrice {
                    HStack {
                        Text("Toplam")
                            .font(CustomFont.regular(size: 14))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("₺\(String(format: "%.2f", totalPrice))")
                            .font(CustomFont.bold(size: 16))
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
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onAppear {
            loadVehicle()
        }
    }
    
    private func loadVehicle() {
        Task {
            do {
                let vehicleDetails = try await VehicleService.shared.getVehicleDetails(car: order.car)
                await MainActor.run {
                    self.vehicle = vehicleDetails
                    self.isLoadingVehicle = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingVehicle = false
                }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd MMM yyyy HH:mm"
            displayFormatter.locale = Locale(identifier: "tr_TR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct StatusBadge: View {
    let state: OrderState
    
    var body: some View {
        Text(state.displayName)
            .font(CustomFont.medium(size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorForState(state))
            )
    }
    
    private func colorForState(_ state: OrderState) -> Color {
        switch state {
        case .pendingApproval, .pendingApprovalLower: return .orange
        case .approved, .approvedLower: return .blue
        case .assigned, .assignedLower: return .purple
        case .inProgress, .inProgressLower: return .yellow
        case .washed, .washedLower: return .green
        case .completed, .completedLower: return .green
        case .canceled, .canceledLower: return .red
        }
    }
}

#Preview {
    OrdersView()
} 