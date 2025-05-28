import SwiftUI

struct CustomInputField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.logo, lineWidth: 1)
            )
            .foregroundColor(.primary)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(true)
    }
}
