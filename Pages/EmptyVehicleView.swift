import SwiftUI

struct EmptyVehicleView: View {
    var onAddVehicle: () -> Void

    var body: some View {
        Button(action: onAddVehicle) {
            VStack {
                Image(systemName: "plus")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.logo)

                Text("Araç Ekle")
                    .font(CustomFont.medium(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, minHeight: 120) // 📌 1:2 oranı
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
            .padding(.horizontal, 16) // Kenarlardan boşluk bırak
        }
    }
}
