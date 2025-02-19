import SwiftUI

struct CustomPickerButton: View {
    var title: String
    var selectedText: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(selectedText ?? title)
                    .foregroundColor(selectedText == nil ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.logo, lineWidth: 1)
            )
        }
    }
}
