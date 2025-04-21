import SwiftUI

struct ModelSelectionView: View {
    var brand: VehicleBrand
    var onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                Spacer()

                Text("Modelini Seç")
                    .font(.title2.bold())
                    .padding(.trailing)
            }
            .padding(.horizontal)
            .padding(.top, 40)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(brand.models, id: \.self) { model in
                        Button(action: {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onSelect(model)
                            }
                        }) {
                            VStack(spacing: 6) {
                                Image("car_logo_placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                                Text(model)
                                    .font(CustomFont.medium(size: 14))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .background(Color("BackgroundColor"))
        .ignoresSafeArea()
    }
}
