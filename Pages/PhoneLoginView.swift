import SwiftUI

enum PhoneLoginStep {
    case phone, code, name, mail
}

struct PhoneLoginView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var step: PhoneLoginStep = .phone
    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var mail: String = ""
    
    // Validations
    var isPhoneValid: Bool {
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phoneNumber)
    }
    var isCodeValid: Bool {
        code.count == 6 && code.allSatisfy { $0.isNumber }
    }
    var isNameValid: Bool {
        name.count > 1 && surname.count > 1
    }
    var isMailValid: Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: mail)
    }
    
    // Focus states
    @FocusState private var isPhoneFieldFocused: Bool
    @FocusState private var isCodeFieldFocused: Bool
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isSurnameFieldFocused: Bool
    @FocusState private var isMailFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            if step == .phone {
                Text("Telefon Numaranız")
                    .font(CustomFont.bold(size: 24))
                    .padding(.bottom, 8)
                HStack(spacing: 0) {
                    Text("+90")
                        .font(CustomFont.bold(size: 20))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)
                        .background(Color(.systemGray6))
                        .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                    TextField("5XXXXXXXXX", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .font(CustomFont.regular(size: 20))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10, corners: [.topRight, .bottomRight])
                        .onChange(of: phoneNumber) { oldValue, newValue in
                            phoneNumber = String(newValue.prefix(10).filter { $0.isNumber })
                        }
                        .focused($isPhoneFieldFocused)
                }
                .frame(maxWidth: 320)
                .padding(.bottom, 8)
                Button(action: { step = .code }) {
                    Text("Mesaj Gönder")
                        .font(CustomFont.bold(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isPhoneValid ? Color.logo : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isPhoneValid)
                .frame(maxWidth: 320)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isPhoneFieldFocused = true }
                }
            } else if step == .code {
                Text("Kodu Girin")
                    .font(CustomFont.bold(size: 24))
                Text("Telefonunuza gönderilen 6 haneli kodu girin.")
                    .font(CustomFont.regular(size: 15))
                    .foregroundColor(.gray)
                HStack(spacing: 12) {
                    ForEach(0..<6) { i in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                                .frame(width: 44, height: 54)
                            Text(code.count > i ? String(code[code.index(code.startIndex, offsetBy: i)]) : "")
                                .font(CustomFont.bold(size: 22))
                        }
                    }
                }
                .frame(maxWidth: 320)
                .onTapGesture { isCodeFieldFocused = true }
                TextField("", text: $code)
                    .keyboardType(.numberPad)
                    .opacity(0.01)
                    .frame(width: 0, height: 0)
                    .onChange(of: code) { oldValue, newValue in
                        code = String(newValue.prefix(6).filter { $0.isNumber })
                    }
                    .focused($isCodeFieldFocused)
                Button(action: { step = .name }) {
                    Text("Devam Et")
                        .font(CustomFont.bold(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCodeValid ? Color.logo : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isCodeValid)
                .frame(maxWidth: 320)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isCodeFieldFocused = true }
                }
            } else if step == .name {
                Text("Adınızı ve soyadınızı öğrenebilir miyiz?")
                    .font(CustomFont.bold(size: 22))
                HStack(spacing: 12) {
                    TextField("Adınız", text: $name)
                        .font(CustomFont.regular(size: 18))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .focused($isNameFieldFocused)
                    TextField("Soyadınız", text: $surname)
                        .font(CustomFont.regular(size: 18))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .focused($isSurnameFieldFocused)
                }
                .frame(maxWidth: 320)
                Button(action: { step = .mail }) {
                    Text("Devam Et")
                        .font(CustomFont.bold(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isNameValid ? Color.logo : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isNameValid)
                .frame(maxWidth: 320)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isNameFieldFocused = true }
                }
            } else if step == .mail {
                Text("Mail adresinizi girin")
                    .font(CustomFont.bold(size: 22))
                TextField("Mail adresi", text: $mail)
                    .font(CustomFont.regular(size: 18))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxWidth: 320)
                    .focused($isMailFieldFocused)
                Button(action: {
                    // Kullanıcı kaydı ve giriş işlemi
                    let newUser = User(
                        id: UUID(),
                        name: name,
                        surname: surname,
                        email: mail,
                        phoneNumber: "+90" + phoneNumber,
                        profileImage: nil,
                        vehicles: []
                    )
                    appState.currentUser = newUser
                    appState.isUserLoggedIn = true
                    appState.tabSelection = .callUs
                    dismissAllSheets()
                }) {
                    Text("Devam Et")
                        .font(CustomFont.bold(size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMailValid ? Color.logo : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isMailValid)
                .frame(maxWidth: 320)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isMailFieldFocused = true }
                }
            }
            Spacer()
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
    
    private func dismissAllSheets() {
        for _ in 0..<3 { dismiss() }
    }
} 