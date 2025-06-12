import SwiftUI

enum AddressSelectionMode {
    case selection  // Adres seçimi için (CallUsView'dan)
    case detail     // Adres detayları için (ProfileView'dan)
}

struct AddressSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAddress: Address?
    let addresses: [Address]
    let onRefresh: () -> Void
    let mode: AddressSelectionMode
    @State private var showAddAddress = false
    @State private var addressesToDelete: Set<String> = []
    @State private var showSwipeHint = false
    @State private var hasShownRealDemo = false
    @State private var showHintBanner = true  // Banner'ın kendisini kontrol eder
    @State private var selectedAddressForDetail: Address?  // Detay sayfası için seçilen adres
    
    var body: some View {
        NavigationStack {
            Group {
                if addresses.isEmpty {
                    emptyStateView
                } else {
                    addressListView
                }
            }
            .navigationTitle("Adres Seç")
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAddress = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.logo)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddAddress) {
            AddAddressView { newAddress in
                Task {
                    do {
                        // CustomerService ile adres ekle - formattedAddress otomatik parse edilecek
                        let _ = try await CustomerService.shared.addAddress(
                            name: newAddress.title,
                            formattedAddress: newAddress.fullAddress,
                            latitude: newAddress.latitude,
                            longitude: newAddress.longitude,
                            street: "",
                            neighborhood: "",
                            district: "",
                            city: "",
                            province: "",
                            postalCode: "",
                            country: "Türkiye"
                        )
                        
                        await MainActor.run {
                            onRefresh() // Adresler listesini refresh et
                            dismiss()
                        }
                    } catch {
                        print("❌ Adres eklenirken hata: \(error)")
                        await MainActor.run {
                dismiss()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: .constant(selectedAddressForDetail != nil), onDismiss: {
            selectedAddressForDetail = nil
        }) {
            if let address = selectedAddressForDetail {
                AddressDetailView(address: address, onAddressUpdated: {
                    onRefresh()
                }, onDismiss: {
                    selectedAddressForDetail = nil
                })
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Henüz adres eklenmemiş")
                .font(CustomFont.medium(size: 18))
                .foregroundColor(.primary)
            
            Text("Yeni bir adres eklemek için + butonuna tıklayın")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
    }
    
    private var addressListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Swipe hint for detail mode (her detail mode açılışında göster)
                if mode == .detail && !addresses.isEmpty && showHintBanner {
                    swipeHintBanner
                }
                
                ForEach(Array(addresses.enumerated()), id: \.element.id) { index, address in
                    Group {
                        if mode == .detail {
                            // Detail mode: Button to open AddressDetailView via sheet
                            Button {
                                selectedAddressForDetail = address
                            } label: {
                    AddressRow(
                        address: address,
                                    isSelected: selectedAddress?.id == address.id,
                                    mode: mode,
                                    onTap: { },
                                    onSwipeToDetail: {
                                        selectedAddressForDetail = address
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                // İlk adres için demo göster
                                if index == 0 && !hasShownRealDemo && mode == .detail {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        showFirstAddressDemo()
                                    }
                                }
                            }
                        } else {
                            // Selection mode: Direct tap to select
                            AddressRow(
                                address: address,
                                isSelected: selectedAddress?.id == address.id,
                                mode: mode,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedAddress = address
                                    }
                                    
                                    // Kısa delay sonra dismiss
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        dismiss()
                                    }
                                },
                                onSwipeToDetail: nil
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("BackgroundColor"))
    }
    
    @ViewBuilder
    private var swipeHintBanner: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 İpucu")
                        .font(CustomFont.bold(size: 14))
                        .foregroundColor(.primary)
                    
                    Text("Adres detaylarını görmek için tıkla veya sola kaydır")
                        .font(CustomFont.regular(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Anladım") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHintBanner = false  // Banner'ı tamamen gizle
                    }
                }
                .font(CustomFont.medium(size: 12))
                .foregroundColor(.logo)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.logo.opacity(0.1))
                .cornerRadius(6)
            }
            
            // Demo animasyonu - her zaman göster
            swipeAnimationDemo
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.logo.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.logo.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .onAppear {
            // Hemen hint animasyonunu başlat
            withAnimation(.easeInOut(duration: 0.3)) {
                showSwipeHint = true
            }
            
            // 4 saniye sonra sadece animasyonu durdur
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSwipeHint = false
                }
            }
        }
    }
    
    @ViewBuilder
    private var swipeAnimationDemo: some View {
        HStack {
            // Mini demo adres kartı
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.logo)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Örnek Adres")
                        .font(CustomFont.medium(size: 12))
                        .foregroundColor(.primary)
                    
                    Text("Detay için sola kaydır")
                        .font(CustomFont.regular(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Animasyonlu ok
                HStack(spacing: 4) {
                    Image(systemName: "hand.draw")
                        .font(.system(size: 12))
                        .foregroundColor(.logo)
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12))
                        .foregroundColor(.logo)
                        .scaleEffect(showSwipeHint ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: showSwipeHint
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
            .offset(x: showSwipeHint ? -20 : 0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: showSwipeHint
            )
            
                         Spacer()
         }
     }
    
    private func showFirstAddressDemo() {
        guard !hasShownRealDemo else { return }
        hasShownRealDemo = true
        
        // İlk adresi hafifçe sola kaydır
        withAnimation(.easeInOut(duration: 0.8)) {
            // Bu animasyon AddressRow'da handle edilecek
        }
    }
}


struct AddressRow: View {
    let address: Address
    let isSelected: Bool
    let mode: AddressSelectionMode
    let onTap: () -> Void
    let onSwipeToDetail: (() -> Void)?  // Swipe navigation için callback
    @State private var isPressed = false
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.logo)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(address.title)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Text(address.fullAddress)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.logo)
            } else if mode == .detail {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            ZStack {
                // Ana arka plan
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                
                // Seçili parıldama efekti (sadece selection mode'da)
                if isSelected && mode == .selection {
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
                
                // Seçili çerçeve (sadece selection mode'da)
                if mode == .selection {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.logo : Color.clear, lineWidth: 2)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
            }
        )
        .offset(x: dragOffset)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
        .gesture(
            // Sadece detail mode'da swipe gesture'ı aktif et
            mode == .detail ? 
            DragGesture()
                .onChanged { value in
                    // Sola kaydırma için daha geniş range
                    let translation = value.translation.width
                    if translation < 0 {
                        isDragging = true
                        // Maksimum -60 pixel sola kaydırma
                        dragOffset = max(translation, -60)
                    }
                }
                .onEnded { value in
                    let translation = value.translation.width
                    let velocity = value.velocity.width
                    
                    isDragging = false
                    
                    // Yeterli swipe (-40 pixel altı veya hızlı) ise navigation aç
                    if translation <= -40 || velocity <= -200 {
                        // AddressDetailView'ı aç
                        onSwipeToDetail?()
                        
                        // Kartı geri döndür
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                            dragOffset = 0
                        }
                        return
                    }
                    
                    // Yetersiz swipe ise sadece geri döndür
                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                        dragOffset = 0
                    }
                } : nil
        )
        .onTapGesture {
            if mode == .selection {
                // Basma animasyonu (sadece selection mode'da)
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
    }
}

#Preview {
    AddressSelectionView(
        selectedAddress: .constant(nil),
        addresses: [],
        onRefresh: {},
        mode: .selection
    )
} 

