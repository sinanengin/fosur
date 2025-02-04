import SwiftUI

struct PasswordField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var validation: Bool = false
    @Binding var isFocused: Bool

    var body: some View {
        HStack {
            HStack {
                if isVisible {
                    TextField(placeholder, text: $text, onEditingChanged: { editing in
                        isFocused = editing
                    })
                } else {
                    SecureField(placeholder, text: $text)
                        .onTapGesture {
                            isFocused = true
                        }
                }
                
                Button(action: {
                    isVisible.toggle()
                }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                      //  .padding(.trailing, validation ? 10 : 10) // Göz ikonu sola kayıyor
                }
            }
            .padding()
            .frame(height: 50) // Yükseklik sabitlendi
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
