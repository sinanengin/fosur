import SwiftUI

// MARK: - TimeSlot Model
struct TimeSlot: Identifiable {
    let id: String
    let time: String
    let isAvailable: Bool
}

struct DateTimeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlot?
    @State private var showTimeSlots = false
    @State private var timeSlots: [TimeSlot] = []
    @State private var isLoading = false
    
    // Animasyon için
    @State private var calendarOffset: CGFloat = 0
    @State private var selectedTimeOffset: CGFloat = 1000
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Takvim Başlığı
                        VStack(spacing: 16) {
                            Text("Ne zaman hizmet almak istersiniz?")
                                .font(CustomFont.bold(size: 24))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("Müsait olduğunuz tarih ve saati seçin")
                                .font(CustomFont.regular(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Takvim
                        VStack(spacing: 16) {
                            DatePicker(
                                "Tarih Seçin",
                                selection: $selectedDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                            .offset(y: calendarOffset)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: calendarOffset)
                            
                            // Seçilen Tarih Gösterici
                            if selectedTimeSlot != nil {
                                selectedDateTimeView
                                    .offset(y: selectedTimeOffset)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTimeOffset)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Saat Seçim Alanı
                        if showTimeSlots {
                            timeSelectionView
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                        
                        // Devam Et Butonu
                        if selectedTimeSlot != nil {
                            continueButton
                                .padding(.horizontal)
                                .padding(.bottom, 32)
                        }
                    }
                }
            }
            .background(Color("BackgroundColor"))
            .navigationBarHidden(true)
            .onChange(of: selectedDate) { _, _ in
                selectedTimeSlot = nil
                showTimeSlots = true
                calendarOffset = -50
                selectedTimeOffset = 1000
                loadTimeSlots()
            }
            .onAppear {
                loadTimeSlots()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                appState.showDateTimeSelection = false
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Tarih & Saat")
                .font(CustomFont.bold(size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Boş alan - buton boyutu için
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Color("BackgroundColor"))
    }
    
    private var selectedDateTimeView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(.logo)
                
                Text(DateFormatter.displayDate.string(from: selectedDate))
                    .font(CustomFont.medium(size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let timeSlot = selectedTimeSlot {
                    Text(timeSlot.time)
                        .font(CustomFont.bold(size: 18))
                        .foregroundColor(.logo)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.logo.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        }
        .padding(.horizontal)
    }
    
    private var timeSelectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saat Seçin")
                .font(CustomFont.bold(size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            if isLoading {
                ProgressView("Müsait saatler yükleniyor...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(timeSlots) { timeSlot in
                            TimeSlotCard(
                                timeSlot: timeSlot,
                                isSelected: selectedTimeSlot?.id == timeSlot.id,
                                onTap: {
                                    if timeSlot.isAvailable {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                            if selectedTimeSlot?.id == timeSlot.id {
                                                selectedTimeSlot = nil
                                                showTimeSlots = true
                                                calendarOffset = 0
                                                selectedTimeOffset = 1000
                                            } else {
                                                selectedTimeSlot = timeSlot
                                                showTimeSlots = false
                                                calendarOffset = -50
                                                selectedTimeOffset = 0
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 80)
            }
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        .padding(.horizontal)
    }
    
    private var continueButton: some View {
        Button(action: {
            guard let timeSlot = selectedTimeSlot else { return }
            
            // NavigationManager'daki siparişi güncelle
            appState.navigationManager.updateOrderDateTime(
                date: selectedDate,
                time: timeSlot.time
            )
            
            // Sipariş özeti sayfasına geç
            appState.navigationManager.showOrderSummaryScreen(appState: appState)
        }) {
            HStack {
                Text("Her şey doğru ise devam edelim")
                    .font(CustomFont.bold(size: 18))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.logo)
            .cornerRadius(16)
            .shadow(color: Color.logo.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private func loadTimeSlots() {
        isLoading = true
        showTimeSlots = true
        
        // API çağrısını simüle et
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            timeSlots = generateTimeSlots()
            isLoading = false
        }
    }
    
    private func generateTimeSlots() -> [TimeSlot] {
        // TODO: Gerçek API'den müsait saatleri al
        // Şimdilik temel saatler göster - API entegrasyonu yapılacak
        var slots: [TimeSlot] = []
        
        // 09:00 - 18:00 arası yarım saat aralıklarla
        for hour in 9...17 {
            for minute in [0, 30] {
                let timeString = String(format: "%02d:%02d", hour, minute)
                // Tüm saatler müsait olarak gösterilir, API'den gerçek bilgi gelecek
                slots.append(TimeSlot(id: UUID().uuidString, time: timeString, isAvailable: true))
            }
        }
        
        return slots
    }
}

// MARK: - Time Slot Card
struct TimeSlotCard: View {
    let timeSlot: TimeSlot
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(timeSlot.time)
                    .font(CustomFont.bold(size: 16))
                    .foregroundColor(textColor)
                
                if !timeSlot.isAvailable {
                    Text("Dolu")
                        .font(CustomFont.regular(size: 12))
                        .foregroundColor(.red)
                }
            }
            .frame(width: 80, height: 60)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .disabled(!timeSlot.isAvailable)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var textColor: Color {
        if !timeSlot.isAvailable {
            return .gray
        } else if isSelected {
            return .white
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if !timeSlot.isAvailable {
            return Color.gray.opacity(0.1)
        } else if isSelected {
            return Color.logo
        } else {
            return Color.white
        }
    }
    
    private var borderColor: Color {
        if !timeSlot.isAvailable {
            return Color.gray.opacity(0.3)
        } else if isSelected {
            return Color.logo
        } else {
            return Color.gray.opacity(0.2)
        }
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        return formatter
    }()
}

#Preview {
    DateTimeSelectionView()
        .environmentObject(AppState())
} 