import SwiftUI

struct FontTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Regular Font Test")
                .font(CustomFont.regular(size: 20))
            
            Text("Bold Font Test")
                .font(CustomFont.bold(size: 20))
            
            Text("Medium Font Test")
                .font(CustomFont.medium(size: 20))
            
            Text("SemiBold Font Test")
                .font(CustomFont.semiBold(size: 20))
            
            Text("ExtraLight Font Test")
                .font(CustomFont.extraLight(size: 20))
            
            Text("Light Font Test")
                .font(CustomFont.light(size: 20))
        }
        .padding()
    }
}

#Preview {
    FontTestView()
}
