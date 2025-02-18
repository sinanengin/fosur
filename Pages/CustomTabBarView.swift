import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .frame(height: 0.5)
                .background(Color.primaryText.opacity(0.2))

            HStack {
                ForEach(TabItem.allCases, id: \.self) { tab in
                    VStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(tab.iconName)
                                    .resizable()
                                    .renderingMode(.template) // İkonun rengini değiştirebilmek için
                                    .scaledToFit()
                                    .frame(width: selectedTab == tab ? 26 : 24, height: selectedTab == tab ? 26 : 24)
                                    .foregroundColor(selectedTab == tab ? Color.logo : Color.primaryText)

                                Text(tab.rawValue)
                                    .font(selectedTab == tab ?
                                          CustomFont.light(size: 11) :
                                          CustomFont.extraLight(size: 11))
                                    .fontWeight(selectedTab == tab ? .medium : .light)
                                    .foregroundColor(selectedTab == tab ? Color.logo : Color.primaryText)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
            .background(Color("BackgroundColor"))
        }
    }
}

#Preview {
    CustomTabBarView(selectedTab: .constant(.callUs))
}
