import SwiftUI

struct FontTestView: View {
    var body: some View {
        VStack {
            Text("Font Test Sayfası")
                .font(.title)

            Button("Yüklü Fontları Göster") {
                for family in UIFont.familyNames {
                    print("Family: \(family)")
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("   \(name)")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    FontTestView()
}
