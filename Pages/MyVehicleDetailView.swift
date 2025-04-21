import SwiftUI

struct MyVehicleDetailView: View {
    let vehicle: Vehicle
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState

    @State private var showEditConfirmation = false
    @State private var showEditVehicle = false

    var body: some View {
        VStack(spacing: 16) {
            // Geri & Kalem
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(.leading, 4)
                }

                Spacer()

                Button(action: {
                    showEditConfirmation = true
                }) {
                    Image("edit_icon") // PNG dosyası olarak projeye eklenmiş olmalı
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal)

            // Araç Görseli
            Image("temp_car")
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Kart
            HStack(spacing: 16) {
                Image("car_logo_placeholder")
                    .resizable()
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicle.brand)
                        .font(CustomFont.bold(size: 16))

                    Text(vehicle.model)
                        .font(CustomFont.regular(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(vehicle.plate)
                    .font(CustomFont.medium(size: 14))
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding(.horizontal)

            // Fotoğraflar
            VStack(alignment: .leading, spacing: 12) {
                Text("Araç Fotoğrafları")
                    .font(CustomFont.medium(size: 16))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(vehicle.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("Aracınızın bilgilerini güncellemek ister misiniz?", isPresented: $showEditConfirmation, titleVisibility: .visible) {
            Button("Evet") {
                showEditVehicle = true
            }
            Button("İptal", role: .cancel) {}
        }
        .sheet(isPresented: $showEditVehicle) {
            EditVehicleView(vehicle: vehicle) { updatedVehicle in
                // Güncellenmiş veriyi AppState'e kaydet
                if let index = appState.currentUser?.vehicles.firstIndex(where: { $0.id == updatedVehicle.id }) {
                    appState.currentUser?.vehicles[index] = updatedVehicle
                }
                showEditVehicle = false
            }
            .environmentObject(appState)
        }
    }
}

#Preview {
    MyVehicleDetailView(vehicle: sampleVehicle)
        .environmentObject(AppState())
}
