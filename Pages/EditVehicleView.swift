import SwiftUI

struct EditVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var vehicle: Vehicle
    var onSave: (Vehicle) -> Void

    @State private var selectedBrandIndex: Int?
    @State private var selectedModel: String?
    @State private var plateCityCode: String
    @State private var plateLetters: String
    @State private var plateNumbers: String
    @State private var exteriorPhotos: [UIImage]
    @State private var interiorPhotos: [UIImage]

    @State private var showBrandSheet = false
    @State private var showModelSheet = false
    @State private var showCityCodePicker = false

    init(vehicle: Vehicle, onSave: @escaping (Vehicle) -> Void) {
        _vehicle = State(initialValue: vehicle)
        _selectedBrandIndex = State(initialValue: vehicleBrands.firstIndex(where: { $0.name == vehicle.brand }))
        _selectedModel = State(initialValue: vehicle.model)
        let plateParts = vehicle.plate.components(separatedBy: " ")
        _plateCityCode = State(initialValue: plateParts.first ?? "")
        _plateLetters = State(initialValue: plateParts.count > 1 ? plateParts[1] : "")
        _plateNumbers = State(initialValue: plateParts.count > 2 ? plateParts[2] : "")
        _exteriorPhotos = State(initialValue: Array(vehicle.images.prefix(2)))
        _interiorPhotos = State(initialValue: Array(vehicle.images.dropFirst(2)))
        self.onSave = onSave
    }

    private var isFormValid: Bool {
        selectedBrandIndex != nil &&
        selectedModel != nil &&
        isPlateValid()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    brandSection
                    modelSection
                    plateSection
                    photoSection
                    saveButton
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
                if let index = selectedBrandIndex {
                    ModelSelectionView(
                        brand: vehicleBrands[index],
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
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Araç Düzenle")
                .font(CustomFont.bold(size: 22))
            Spacer().frame(width: 24)
        }
    }

    private var brandSection: some View {
        CustomPickerButton(
            title: "Marka Seç",
            selectedText: selectedBrandIndex.map { vehicleBrands[$0].name }
        ) {
            showBrandSheet = true
        }
    }

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
        } else {
            return AnyView(EmptyView())
        }
    }

    private var plateSection: some View {
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
    }

    private var photoSection: some View {
        VStack(spacing: 16) {
            PhotoGroupUploadView(title: "Araç Dış Fotoğrafları", selectedImages: $exteriorPhotos)
            PhotoGroupUploadView(title: "Araç İç Mekan Fotoğrafları", selectedImages: $interiorPhotos)
        }
    }

    private var saveButton: some View {
        Button {
            saveChanges()
        } label: {
            Text("Kaydet")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.logo : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!isFormValid)
    }

    private var cityCodePicker: some View {
        NavigationStack {
            Picker("İl Kodu Seç", selection: $plateCityCode) {
                ForEach(1...81, id: \.self) { code in
                    let value = code < 10 ? "0\(code)" : "\(code)"
                    Text(value).tag(value)
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

    private func saveChanges() {
        guard let brandIndex = selectedBrandIndex else { return }

        vehicle.brand = vehicleBrands[brandIndex].name
        vehicle.model = selectedModel ?? ""
        vehicle.plate = "\(plateCityCode) \(plateLetters) \(plateNumbers)"
        vehicle.images = exteriorPhotos + interiorPhotos

        onSave(vehicle)
        dismiss()
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
