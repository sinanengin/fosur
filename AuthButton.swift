import SwiftUI

struct AuthButton: View {
    var title: String
    var imageName: String
    var isSystemImage: Bool = false
    var action: () -> Void // Dışarıdan fonksiyon alacak

    var body: some View {
        Button(action: {
            action()
            print("\(title) tıklandı")
        }) {
            HStack(spacing: 10) { // İkon ve yazı arasındaki boşluk
                if isSystemImage {
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))

            }
            
            .foregroundColor(Color.logo)
            .frame(maxWidth: .infinity, minHeight: 50) // Buton genişliği tam olacak, yüksekliği sabit
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.logo, lineWidth: 1)
            )
        }
    }
}



