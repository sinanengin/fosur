import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 12) {
            Image("temp_car")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 70)
                .clipped()
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(vehicle.brand)
                        .font(CustomFont.bold(size: 16))
                    Text(vehicle.model)
                        .font(CustomFont.medium(size: 16))
                }

                Text(vehicle.plate)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}
