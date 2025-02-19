import SwiftUI

struct AddVehicleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var selectedBrandIndex: Int? = nil
    @State private var selectedModel: String? = nil

    @State private var plateCityCode: String = ""
    @State private var plateLetters: String = ""
    @State private var plateNumbers: String = ""

    @State private var uploadedPhotos: [UIImage] = Array(repeating: UIImage(systemName: "plus")!, count: 4)

    @State private var showExitConfirmation = false

    @State private var showBrandPicker = false
    @State private var showModelPicker = false
    @State private var showCityCodePicker = false

    var isFormValid: Bool {
        selectedBrandIndex != nil &&
        selectedModel != nil &&
        isPlateValid()
    }
    private func isPlateValid() -> Bool {
        let lettersCount = plateLetters.count
        let numbersCount = plateNumbers.count

        switch lettersCount {
        case 1:
            return numbersCount == 4
        case 2:
            return numbersCount == 3 || numbersCount == 4
        case 3:
            return numbersCount == 2
        default:
            return false
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Üstte sadece Geri tuşu
            HStack {
                Button(action: { checkBeforeExit() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)

            Text("Araç Ekle")
                .font(CustomFont.bold(size: 24))
                .padding(.horizontal)

            // MARKA SEÇİMİ
            VStack(alignment: .leading, spacing: 4) {
                Text("Marka")
                    .font(CustomFont.medium(size: 14))
                    .foregroundColor(.gray)

                CustomPickerButton(
                    title: "Marka Seç",
                    selectedText: selectedBrandIndex != nil ? vehicleBrands[selectedBrandIndex!].name : nil
                ) {
                    showBrandPicker = true
                }
            }
            .padding(.horizontal)

            // MODEL SEÇİMİ
            if let selectedBrandIndex {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Model")
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(.gray)

                    CustomPickerButton(
                        title: "Model Seç",
                        selectedText: selectedModel
                    ) {
                        showModelPicker = true
                    }
                }
                .padding(.horizontal)
            }

            // PLAKA GİRİŞİ
            if selectedModel != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plaka")
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(.gray)

                    HStack(spacing: 8) {
                        Button(action: {
                            showCityCodePicker = true
                        }) {
                            Text(plateCityCode.isEmpty ? "İl Kodu" : plateCityCode)
                                .foregroundColor(plateCityCode.isEmpty ? .gray : .primary)
                                .frame(width: 70, height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.logo, lineWidth: 1))
                        }

                        CustomInputField(placeholder: "ABC", text: $plateLetters)
                            .frame(width: 80)
                            .textInputAutocapitalization(.characters)
                            .onChange(of: plateLetters) { plateLetters = plateLetters.uppercased() }

                        CustomInputField(placeholder: "1234", text: $plateNumbers)
                            .frame(width: 100)
                            .keyboardType(.numberPad)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Araç Fotoğrafları")
                        .font(CustomFont.medium(size: 14))
                        .foregroundColor(.gray)

                    PhotoUploadView(images: $uploadedPhotos)
                }
                .padding(.horizontal)
            }

            Spacer()

            Button(action: {
                let newVehicle = Vehicle(
                    id: UUID(),
                    brand: vehicleBrands[selectedBrandIndex!].name,
                    model: selectedModel ?? "",
                    plate: "\(plateCityCode) \(plateLetters) \(plateNumbers)",
                    type: .suv,
                    images: uploadedPhotos,
                    userId: appState.currentUser?.id ?? UUID(),
                    lastServices: []
                )
                appState.currentUser?.vehicles.append(newVehicle)
                dismiss()
            }) {
                Text("Aracımı Ekle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.logo : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(!isFormValid)
        }
        .navigationBarBackButtonHidden(true) // Mavi "Back" yazısını kaldırıyoruz
        .sheet(isPresented: $showBrandPicker) {
            brandPicker
        }
        .sheet(isPresented: $showModelPicker) {
            modelPicker
        }
        .sheet(isPresented: $showCityCodePicker) {
            cityCodePicker
        }
        .confirmationDialog(
            "Girdiğiniz bilgiler silinecektir. Emin misiniz?",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Vazgeç", role: .cancel) { }
            Button("Sil", role: .destructive) { dismiss() }
        }
    }

    // MARKA PICKER
    private var brandPicker: some View {
        NavigationStack {
            Picker("Marka Seç", selection: $selectedBrandIndex) {
                ForEach(vehicleBrands.indices, id: \.self) { index in
                    Text(vehicleBrands[index].name).tag(Optional(index))
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Marka Seç")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { showBrandPicker = false }
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
    }

    // MODEL PICKER
    private var modelPicker: some View {
        NavigationStack {
            Picker("Model Seç", selection: $selectedModel) {
                ForEach(vehicleBrands[selectedBrandIndex!].models, id: \.self) { model in
                    Text(model).tag(Optional(model))
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Model Seç")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { showModelPicker = false }
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
    }

    // İL KODU PICKER
    private var cityCodePicker: some View {
        NavigationStack {
            Picker("İl Kodu Seç", selection: $plateCityCode) {
                ForEach(1...81, id: \.self) { code in
                    Text("\(code)").tag("\(code)")
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("İl Kodu Seç")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") { showCityCodePicker = false }
                }
            }
            .presentationDetents([.fraction(0.3)])
        }
    }

    private func checkBeforeExit() {
        if hasFilledData() {
            showExitConfirmation = true
        } else {
            dismiss()
        }
    }

    private func hasFilledData() -> Bool {
        selectedBrandIndex != nil || selectedModel != nil || !plateCityCode.isEmpty || !plateLetters.isEmpty || !plateNumbers.isEmpty
    }
}
