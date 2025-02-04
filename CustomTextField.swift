import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var validation: Bool = false
    @Binding var isFocused: Bool

    var body: some View {
        HStack {
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                isFocused = editing
            })
            .padding()
            .frame(height: 50) // Yükseklik sabitlendi, artık genişlemiyor.
            .frame(maxWidth: validation ? .infinity : .infinity, alignment: .leading) // Sola yaslı küçülme
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(validation || isFocused ? Color.logo : Color.secondary, lineWidth: 2)
                    .animation(.easeInOut(duration: 0.2), value: isFocused || validation)
            )

            if validation {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .padding(.trailing, 10)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: validation)
    }
}
