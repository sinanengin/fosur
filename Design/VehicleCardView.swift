import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image("temp_car")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 70)
                    .clipped()
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(vehicle.brand)
                            .font(CustomFont.bold(size: 16))
                            .foregroundColor(.primary)
                        Text(vehicle.model)
                            .font(CustomFont.medium(size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    Text(vehicle.plate)
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}
