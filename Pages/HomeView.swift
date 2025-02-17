import SwiftUI

struct HomeView: View {
    @State private var selectedTab: TabItem = .callUs

    var body: some View {
        VStack {
            Spacer()

            TabView(selection: $selectedTab) {
                CampaignsView().tag(TabItem.campaigns)
                MyVehiclesView().tag(TabItem.myVehicles)
                CallUsView().tag(TabItem.callUs)
                MessagesView().tag(TabItem.messages)
                ProfileView().tag(TabItem.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Sayfa geçiş efekti için

            CustomTabBarView(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom) // TabBar'ı ekrana yapışık yapalım
        .background(Color("BackgroundColor"))
    }
}


#Preview {
    HomeView()
}
