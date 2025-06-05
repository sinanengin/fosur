import SwiftUI
import PhotosUI

struct PhotoGroupUploadView: View {
    let title: String
    @Binding var selectedImages: [UIImage]
    let maxImages: Int

    @State private var isImagePickerPresented = false
    @State private var pickerConfig = PHPickerConfiguration()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(CustomFont.medium(size: 14))
                .foregroundColor(.gray)

            VStack(spacing: 12) {
                if selectedImages.isEmpty {
                    uploadPlaceholder
                } else {
                    photoGrid
                }

                if selectedImages.count < 4 {
                    Button(action: { isImagePickerPresented = true }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Fotoğraf Ekle")
                        }
                        .foregroundColor(Color.logo)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.logo, lineWidth: 1)
                        )
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .photosPicker(
            isPresented: $isImagePickerPresented,
            selection: .constant([]),
            matching: .images,
            preferredItemEncoding: .automatic,
            photoLibrary: .shared()
        )
        .onChange(of: selectedImages) { oldValue, newValue in
            if newValue.count > maxImages {
                selectedImages = Array(newValue.prefix(maxImages))
            }
        }
    }

    private var uploadPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .foregroundColor(.gray.opacity(0.5))
            .frame(height: 120)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray.opacity(0.7))

                    Text("Fotoğraf eklemek için butona basın")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            )
    }

    private var photoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(selectedImages.indices, id: \.self) { index in
                Image(uiImage: selectedImages[index])
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(10)
            }
        }
    }

    private func loadPhotos() {
        // Gelecekte entegre edilecek
        // Seçilen fotoğrafları PHPicker üzerinden almak için kullanılır
    }
}
