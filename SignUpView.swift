import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var agreeToTerms = false
    @State private var agreeToPrivacy = false

    @State private var isFirstNameFocused = false
    @State private var isLastNameFocused = false
    @State private var isPhoneNumberFocused = false
    @State private var isEmailFocused = false
    @State private var isPasswordFocused = false
    @State private var isConfirmPasswordFocused = false

    var isFormValid: Bool {
        return firstName.count >= 3 &&
               lastName.count >= 2 &&
               phoneNumber.count >= 10 &&
               isValidEmail(email) &&
               isValidPassword(password) &&
               password == confirmPassword &&
               agreeToTerms && agreeToPrivacy
    }

    var body: some View {
        VStack {
            // Geri Dön Butonu ve Logo Aynı Hizaya Getirildi
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25) // Buton büyütüldü
                        .foregroundColor(.gray)
                }
                
                Image("fosur_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170, height: 130) // Logo büyütüldü.
                    .padding(.leading, 66)
                Spacer()
            }
            .padding(.horizontal)

            Text("Hesap Oluştur")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 25)

            VStack(spacing: 16) {
                CustomTextField(placeholder: "Ad", text: $firstName, validation: firstName.count >= 3, isFocused: $isFirstNameFocused)
                CustomTextField(placeholder: "Soyad", text: $lastName, validation: lastName.count >= 2, isFocused: $isLastNameFocused)
                CustomTextField(placeholder: "Telefon Numarası", text: $phoneNumber, validation: phoneNumber.count >= 10, isFocused: $isPhoneNumberFocused)
                CustomTextField(placeholder: "E-Posta", text: $email, validation: isValidEmail(email), isFocused: $isEmailFocused)
                
                PasswordField(placeholder: "Şifre", text: $password, isVisible: $isPasswordVisible, validation: isValidPassword(password), isFocused: $isPasswordFocused)

                PasswordField(placeholder: "Şifre Tekrar", text: $confirmPassword, isVisible: $isConfirmPasswordVisible, validation: !confirmPassword.isEmpty && confirmPassword == password, isFocused: $isConfirmPasswordFocused)


                AgreementSection(agreeToTerms: $agreeToTerms, agreeToPrivacy: $agreeToPrivacy)
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                print("Kayıt Ol Butonuna Basıldı")
            }) {
                Text("Hesap Oluştur")
                    .font(.headline)
                    .foregroundColor(isFormValid ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.logo : Color.gray.opacity(0.5))
                    .cornerRadius(12)
            }
            .disabled(!isFormValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 40) // Buton yukarı çekildi
        }
    }



    // 📌 E-Posta Doğrulama Fonksiyonu
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    // 📌 Şifre Doğrulama Fonksiyonu
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[!@#$&*]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}

#Preview {
    SignUpView()
}
