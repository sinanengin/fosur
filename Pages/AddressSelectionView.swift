import SwiftUI

struct AddressSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAddress: Address?
    let addresses: [Address]
    @State private var showAddAddress = false
    @State private var addressesToDelete: Set<String> = []
    
    var body: some View {
        NavigationStack {
            Group {
                if addresses.isEmpty {
                    emptyStateView
                } else {
                    addressListView
                }
            }
            .navigationTitle("Adres Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddAddress = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.logo)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddAddress) {
            AddAddressView { newAddress in
                Task {
                    try? await OrderAPIService.shared.addAddress(newAddress)
                    await MainActor.run {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Henüz adres eklenmemiş")
                .font(CustomFont.medium(size: 18))
                .foregroundColor(.primary)
            
            Text("Yeni bir adres eklemek için + butonuna tıklayın")
                .font(CustomFont.regular(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundColor"))
    }
    
    private var addressListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(addresses) { address in
                    AddressRow(
                        address: address,
                        isSelected: selectedAddress?.id == address.id
                    )
                    .onTapGesture {
                        selectedAddress = address
                        dismiss()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                try? await OrderAPIService.shared.deleteAddress(id: address.id)
                                await MainActor.run {
                                    if selectedAddress?.id == address.id {
                                        selectedAddress = nil
                                    }
                                }
                            }
                        } label: {
                            Label("Sil", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
    }
}

struct AddressRow: View {
    let address: Address
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.logo)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(address.title)
                    .font(CustomFont.medium(size: 16))
                    .foregroundColor(.primary)
                
                Text(address.fullAddress)
                    .font(CustomFont.regular(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.logo)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
        )
    }
}

#Preview {
    AddressSelectionView(
        selectedAddress: .constant(nil),
        addresses: []
    )
} 