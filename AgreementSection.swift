import SwiftUI

struct AgreementSection: View {
    @Binding var agreeToTerms: Bool
    @Binding var agreeToPrivacy: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $agreeToTerms) {
                Text("KVKK Şartlarını Onaylıyorum")
                    .foregroundColor(.primary)
            }

            Toggle(isOn: $agreeToPrivacy) {
                Text("Gizlilik Politikasını Onaylıyorum")
                    .foregroundColor(.primary)
            }
        }
        .padding(.top, 10)
    }
}
