import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: TabItem

    var body: some View {
        HStack {
            ForEach(TabItem.allCases, id: \.self) { tab in
                VStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: tab.icon)
                                .font(.system(size: selectedTab == tab ? 22 : 20, weight: selectedTab == tab ? .bold : .light)) // Kalınlık animasyonu
                                .foregroundColor(selectedTab == tab ? Color.logo : Color.primaryText)

                            Text(tab.rawValue)
                                .font(selectedTab == tab ?
                                      CustomFont.light(size: 10) : // Seçili: Light
                                      CustomFont.extraLight(size: 10)) // Seçili değil: ExtraLight
                                .foregroundColor(selectedTab == tab ? Color.logo : Color.primaryText)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Alt çizgi İSTERSEK, animasyonlu yapabiliriz
                    if selectedTab == tab {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color.logo)
                            .padding(.top, 2)
                            .transition(.opacity)
                    } else {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.clear)
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16) // Sağdan soldan boşluk
        .padding(.top, 6) // Üstten biraz boşluk
        .padding(.bottom, 24) // Home Indicator boşluğu için aşağıdan fazla boşluk
        .background(Color("BackgroundColor"))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: -2)
        .animation(.easeInOut(duration: 0.2), value: selectedTab) // Bütün değişiklikleri kapsayan animasyon
    }
}

#Preview {
    CustomTabBarView(selectedTab: .constant(.callUs))
}
