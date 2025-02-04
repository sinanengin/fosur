import SwiftUI

struct LogoView: View {
    var body: some View {
        Image("fosur_logo")
            .resizable()
            .scaledToFit()
            .frame(width: 250, height: 250)
            .padding(.bottom, 40)
    }
}

#Preview {
    LogoView()
}
