import SwiftUI

struct TermsPopupView: View {
    @Binding var isPresented: Bool
    var title: String
    var content: String

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Hafif şeffaf arka plan
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    closePopup()
                }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()

                    // X Butonu (Kapatma)
                    Button(action: {
                        closePopup()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)

                ScrollView {
                    Text(content)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                        .padding()
                }
                .frame(maxHeight: 300)

            }
            .padding()
            .frame(width: 350) // Genişliği biraz artırdık
            .background(Color("BackgroundColor"))
            .cornerRadius(20)
            .shadow(radius: 10)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 1
                    scale = 1
                }
            }
        }
    }

    private func closePopup() {
        withAnimation(.easeIn(duration: 0.2)) {
            opacity = 0
            scale = 0.8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
        }
    }
}
