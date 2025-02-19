import SwiftUI

struct PhotoUploadView: View {
    @Binding var images: [UIImage]

    var body: some View {
        HStack {
            ForEach(0..<images.count, id: \.self) { index in
                ZStack {
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .background(Color.white)
                        .clipped()

                    if images[index] == UIImage(systemName: "plus")! {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                .onTapGesture {
                    // Fotoğraf yükleme işlevi burada olacak
                    print("Fotoğraf \(index + 1) seçildi")
                }
            }
        }
    }
}
