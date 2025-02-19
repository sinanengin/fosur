import SwiftUI

struct CategoryButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CustomFont.medium(size: 14))
                .foregroundColor(isSelected ? .white : Color.primaryText)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.primaryText : Color.primaryText.opacity(0.1))
                .cornerRadius(20)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    CategoryButton(title: "Tümü", isSelected: true) {}
}
