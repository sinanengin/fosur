import SwiftUI

struct DividerWithOr: View {
    var body: some View {
        HStack {
            VStack { Divider().background(Color.gray) }
            Text("veya")
                .font(.footnote) // Daha küçük font
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            VStack { Divider().background(Color.gray) }
        }
        .padding(.horizontal, 24)
    }
}
