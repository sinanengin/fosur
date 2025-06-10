import SwiftUI

struct BrandSelectionView: View {
    @Environment(\.dismiss) var dismiss
    var brands: [MockVehicleBrand]
    var onSelect: (Int) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(brands.indices, id: \.self) { index in
                    Button(action: {
                        onSelect(index)
                        dismiss()
                    }) {
                        HStack {
                            Text(brands[index].name)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Marka Seçin")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("İptal") { dismiss() }
            )
        }
    }
}
