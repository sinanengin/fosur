import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        HStack {
            Image(systemName: "car.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)

            VStack(alignment: .leading) {
                Text(vehicle.brand)
                    .font(CustomFont.bold(size: 16))

                Text(vehicle.model)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.gray)

                Text(vehicle.type.rawValue)
                    .font(CustomFont.regular(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VehicleCardView(vehicle: Vehicle(
        id: UUID(),
        brand: "Ford",
        model: "Focus",
        plate: "34 ABC 123",
        type: .automobile, // Artık enum böyle kullanılır
        images: [],
        userId: UUID(),
        lastServices: []
    ))
}
