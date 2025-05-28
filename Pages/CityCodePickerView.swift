import SwiftUI

struct CityCodePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCityCode: String
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("İl Kodu Seç", selection: $selectedCityCode) {
                    ForEach(1...81, id: \.self) { code in
                        let value = code < 10 ? "0\(code)" : "\(code)"
                        Text(value).tag(value)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("İl Kodu Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.fraction(0.3)])
    }
}

#Preview {
    CityCodePickerView(selectedCityCode: .constant("34"))
} 