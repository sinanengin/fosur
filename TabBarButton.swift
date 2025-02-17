import SwiftUI

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .foregroundColor(isSelected ? Color.logo : Color.primaryText)
                    .font(.system(size: 20, weight: .bold))

                if isSelected {
                    Text(tab.rawValue)
                        .foregroundColor(Color.logo)
                        .font(.system(size: 14, weight: .semibold))
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, isSelected ? 12 : 0)
            .padding(.vertical, 8)
            .background(isSelected ? Color("BackgroundColor") : Color.clear)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
