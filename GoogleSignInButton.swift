import SwiftUI

struct GoogleSignInButton: View {
    var body: some View {
        Button(action: {
            print("Google ile giriş yapılacak")
        }) {
            HStack {
                Image(systemName: "g.circle.fill")
                    .foregroundColor(.red)
                Text("Google ile Giriş Yap")
                    .foregroundColor(.black)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 4)
        }
        .padding(.top, 10)
    }
}
