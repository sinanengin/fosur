import SwiftUI

struct EmptyVehicleView: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text("Araç Ekle")
                    .font(CustomFont.medium(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    EmptyVehicleView {}
}
