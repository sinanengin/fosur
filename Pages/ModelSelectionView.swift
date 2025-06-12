import SwiftUI

struct ModelSelectionView: View {
    var brand: MockVehicleBrand
    var onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(brand.models.sorted(), id: \.self) { model in
                Button(action: {
                        onSelect(model)
                    dismiss()
                }) {
                        HStack {
                            Text(model)
                        .foregroundColor(.primary)
                Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Model Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("İptal") { dismiss() }
            )
        }
    }
}
