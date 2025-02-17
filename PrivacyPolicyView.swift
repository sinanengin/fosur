import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Gizlilik Politikası")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Güvenilirlik konusundaki taahhütlerimiz doğrultusunda, hizmetlerimizde insanların kendilerini gerçeğe uygun olmayan şekilde tanıtmasına, sahte hesaplar kullanmasına, içeriğin popülerliğini yapay olarak artırmasına veya Topluluk Standartlarımız kapsamındaki diğer ihlallere yol açmak için tasarlanan davranışlarda bulunmasına izin vermiyoruz. Gerçeğe Uygun Olmayan Davranışlar, Meta'yı veya topluluğumuzu aldatmak ya da Topluluk Standartları kapsamındaki yaptırımlardan kaçınmak amacıyla, aynı kişi veya kişiler tarafından kontrol edilen bir gerçeğe uygun olmayan varlık ağının gerçekleştirdiği, çok çeşitli ve karmaşık aldatma biçimleri anlamına gelir Çekişmeli tehdit aktörleri herkese açık tartışmalara etki etme amacıyla Gerçeğe Uygun Olmayan sofistike taktiklere başvurmak için sahte hesaplar kullandığında; Koordinasyon Halinde, Gerçeğe Uygun Olmayan Davranışlar gerçekleştirmiş, yani stratejik bir hedef uğruna herkese açık tartışmaları manipüle etmek için sahte hesapların operasyonda merkezi rol oynadığı koordine çalışmalar yürütmüş olur. Aldatmaya yönelik çalışmalarının daha büyük çaplı ve sofistike olması nedeniyle, ihlalde bulunan bu davranışlara nispeten ağır ve genellikle kendilerine özel müdahale uygulanır. Koordinasyon Halinde, Gerçeğe Uygun Olmayan Davranış ağları hakkındaki bulgularımızı, mümkün olduğu sürece burada bulabileceğiniz Üç Aylık Çekişmeli Tehdit Raporlarımızda paylaşırız. Bu raporlar Gerçeğe Uygun Olmayan Davranışlar ilkesi kapsamındaki yaptırım evreninin tamamını kapsamayı değil, bu alanda karşılaştığımız tehditlerin evrilen niteliğini topluluğumuzun daha iyi anlamasını amaçlar.Gerçeğe Uygun Olmayan Davranışlar genellikle toplumsal veya siyasi içeriklerle ilişkilendirilmekle birlikte, seçim bağlamında Gerçeğe Uygun Olmayan Davranışları önlemeye büyük önem veririz. Bu yaptırım işlemleri ve standartları, siyasi olup olmaması fark etmeksizin, içerikten bağımsız olarak geçerlidir. Bu ilkenin amacı, hizmetlerimizdeki tartışma ve konuşmaların güvenilirliğini korumak ve insanların etkileşimde bulundukları kişilere ve topluluklara güvenebileceği bir ortam yaratmaktır.")

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Gizlilik Politikası")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview {
    PrivacyPolicyView()
}
