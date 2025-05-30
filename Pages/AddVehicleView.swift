import SwiftUI

struct AddVehicleView: View {
    var onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var selectedBrandIndex: Int? = nil
    @State private var selectedModel: String? = nil

    @State private var plateCityCode: String = ""
    @State private var plateLetters: String = ""
    @State private var plateNumbers: String = ""

    @State private var exteriorPhotos: [UIImage] = []
    @State private var interiorPhotos: [UIImage] = []

    @State private var showExitConfirmation = false
    @State private var showBrandSheet = false
    @State private var showModelSheet = false
    @State private var showCityCodePicker = false

    private var isFormValid: Bool {
        selectedBrandIndex != nil &&
        selectedModel != nil &&
        isPlateValid()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    brandSection
                
                    modelSection
                    plateSection
                    if selectedModel != nil {
                        photoUploadSection
                        submitButton
                    }
                }
                .padding()
            }
            .background(Color("BackgroundColor"))
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $showBrandSheet) {
                BrandSelectionView(
                    brands: vehicleBrands,
                    onSelect: { index in
                        selectedBrandIndex = index
                        selectedModel = nil
                        showBrandSheet = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showModelSheet) {
                if let brandIndex = selectedBrandIndex {
                    ModelSelectionView(
                        brand: vehicleBrands[brandIndex],
                        onSelect: { model in
                            selectedModel = model
                            showModelSheet = false
                        }
                    )
                }
            }
            .sheet(isPresented: $showCityCodePicker) {
                cityCodePicker
            }
            .confirmationDialog(
                "Girdiğiniz bilgiler silinecektir. Emin misiniz?",
                isPresented: $showExitConfirmation,
                titleVisibility: .visible
            ) {
                Button("Vazgeç", role: .cancel) {}
                Button("Sil", role: .destructive) {
                    dismiss()
                    onDismiss()
                }
            }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button {
                checkBeforeExit()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Araç Ekle")
                .font(CustomFont.bold(size: 22))
            Spacer().frame(width: 24)
        }
    }

    // MARK: - Marka Seç
    private var brandSection: some View {
        CustomPickerButton(
            title: "Marka Seç",
            selectedText: selectedBrandIndex != nil ? vehicleBrands[selectedBrandIndex!].name : nil
        ) {
            showBrandSheet = true
        }
    }

    // MARK: - Model Seç
    private var modelSection: some View {
        if selectedBrandIndex != nil {
            return AnyView(
                CustomPickerButton(
                    title: "Model Seç",
                    selectedText: selectedModel
                ) {
                    showModelSheet = true
                }
            )
        }
        return AnyView(EmptyView())
    }

    // MARK: - Plaka Giriş
    private var plateSection: some View {
        if selectedModel != nil {
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text("Plaka")
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(.gray)

                    HStack(spacing: 12) {
                        Button {
                            showCityCodePicker = true
                        } label: {
                            Text(plateCityCode.isEmpty ? "01-81" : plateCityCode)
                                .foregroundColor(plateCityCode.isEmpty ? .gray : .primary)
                                .frame(width: 80, height: 50)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.logo))
                        }

                        CustomInputField(placeholder: "ABC", text: $plateLetters)
                            .onChange(of: plateLetters) {
                                plateLetters = plateLetters.uppercased().filter { $0.isLetter }
                            }
                            .frame(width: 80)

                        CustomInputField(placeholder: "1234", text: $plateNumbers)
                            .keyboardType(.numberPad)
                            .onChange(of: plateNumbers) {
                                plateNumbers = plateNumbers.filter { $0.isNumber }
                            }
                            .frame(width: 100)
                    }
                }
            )
        }
        return AnyView(EmptyView())
    }

    // MARK: - Fotoğraf Bölümü
    private var photoUploadSection: some View {
        VStack(spacing: 16) {
            PhotoGroupUploadView(title: "Araç Dış Fotoğrafları", selectedImages: $exteriorPhotos)
            PhotoGroupUploadView(title: "Araç İç Mekan Fotoğrafları", selectedImages: $interiorPhotos)
        }
    }

    // MARK: - Kaydet Butonu
    private var submitButton: some View {
        Button {
            saveVehicle()
        } label: {
            Text("Aracımı Ekle")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.logo : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!isFormValid)
    }

    // MARK: - İl Kodu Picker
    private var cityCodePicker: some View {
        NavigationStack {
            Picker("İl Kodu Seç", selection: $plateCityCode) {
                Text("Seçiniz").tag("")
                ForEach(1...81, id: \.self) { code in
                    Text(code < 10 ? "0\(code)" : "\(code)").tag(code < 10 ? "0\(code)" : "\(code)")
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("İl Kodu Seç")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        showCityCodePicker = false
                    }
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
    }

    // MARK: - Kayıt Fonksiyonu
    private func saveVehicle() {
        guard let brandIndex = selectedBrandIndex else { return }

        let newVehicle = Vehicle(
            id: UUID(),
            brand: vehicleBrands[brandIndex].name,
            model: selectedModel ?? "",
            plate: "\(plateCityCode) \(plateLetters) \(plateNumbers)",
            type: .automobile,
            images: exteriorPhotos + interiorPhotos,
            userId: appState.currentUser?.id ?? UUID(),
            lastServices: []
        )

        appState.currentUser?.vehicles.append(newVehicle)
        dismiss()
        onDismiss()
    }

    private func checkBeforeExit() {
        if selectedBrandIndex != nil || selectedModel != nil || !plateCityCode.isEmpty || !plateLetters.isEmpty || !plateNumbers.isEmpty {
            showExitConfirmation = true
        } else {
            dismiss()
            onDismiss()
        }
    }

    private func isPlateValid() -> Bool {
        let lettersCount = plateLetters.count
        let numbersCount = plateNumbers.count

        switch lettersCount {
        case 1: return numbersCount == 4
        case 2: return numbersCount == 3 || numbersCount == 4
        case 3: return numbersCount == 2
        default: return false
        }
    }
}
