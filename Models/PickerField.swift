import SwiftUI

struct PickerField: View {
    var title: String
    @Binding var selection: String
    var options: [String]
    var displayText: (String) -> String

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { item in
                Button(action: {
                    selection = item
                }) {
                    Text(displayText(item))
                }
            }
        } label: {
            HStack {
                Text(selection.isEmpty ? title : displayText(selection))
                    .foregroundColor(selection.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.logo))
        }
    }
}
