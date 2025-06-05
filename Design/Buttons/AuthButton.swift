import SwiftUI

struct AuthButton: View {
    var title: String
    var imageName: String
    var isSystemImage: Bool = false
    var action: () -> Void // Dışarıdan fonksiyon alacak
    
    @State private var isProcessing = false // Çoklu tıklama koruması

    var body: some View {
        Button(action: {
            guard !isProcessing else { 
                print("⚠️ AuthButton (\(title)): Zaten işleniyor, çıkıyor...")
                return 
            }
            isProcessing = true
            
            action()
            print("🔘 AuthButton: \(title) tıklandı")
            
            // 1 saniye sonra reset et
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isProcessing = false
                print("🔘 AuthButton (\(title)): isProcessing reset edildi")
            }
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
            
            .foregroundColor(isProcessing ? Color.gray : Color.logo)
            .frame(maxWidth: .infinity, minHeight: 50) // Buton genişliği tam olacak, yüksekliği sabit
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isProcessing ? Color.gray : Color.logo, lineWidth: 1)
            )
        }
        .disabled(isProcessing) // Processing sırasında disabled
    }
}



