//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject private var session: WayPay.Session
    @State private var email: String = String(){
        didSet {
            UserDefaults.standard.set(email, forKey: WayPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    @State private var name = String()
    var firstName: String {
        let components = name.components(separatedBy: " ")
        if components.isEmpty {
            return "-"
        }
        return components.first!
    }
    var lastName: String {
        let components = name.components(separatedBy: " ")
        if components.count > 1 {
            return components[1]
        }
        return "-"
    }

    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    @State var loginError: Bool = false
    @State private var businessName = String()
    @State private var phoneNumber = String()
    @State private var logo: UIImage? = UIImage(named: WayPay.Merchant.defaultLogo)
    @State private var showImagePicker: Bool = false

    private var shouldRegistrationButtonBeDisabled: Bool {
        return (!WayAppUtils.validateEmail(email) || newPIN.count != WayPay.Account.PINLength) || businessName.isEmpty
    }
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                Image("WayPay-Hands")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.horizontal)
                Spacer()
            }
            Section(header: Label(NSLocalizedString("My account", comment: "SettingsView: section title"), systemImage: "person.fill")
                        .accessibility(label: Text("My account"))
                        .font(.callout)) {
                TextField("name", text: self.$name)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .textContentType(.name)
                TextField("email address", text: self.$email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                TextField("4-digit PIN", text: self.$newPIN)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .foregroundColor((newPIN.count == WayPay.Account.PINLength) ? .primary : .red)
                TextField("confirm PIN", text: self.$confirmationPIN)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .foregroundColor((confirmationPIN.count == WayPay.Account.PINLength && newPIN == confirmationPIN) ? .primary : .red)
            }
            Section(header:
                        Label(NSLocalizedString("My business", comment: "SettingsView: section title"), systemImage: "greetingcard.fill")
                        .font(.callout)) {
                TextField("business name", text: self.$businessName)
                    .disableAutocorrection(true)
                    .textContentType(.organizationName)
                TextField("phone number", text: self.$phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                HStack {
                    Button(action: {
                        self.showImagePicker = true
                    }, label: {
                        Label(NSLocalizedString("Logo", comment: "business logo"), systemImage: "camera.fill")
                            .padding()
                    })
                    .sheet(isPresented: self.$showImagePicker) {
                        PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$logo)
                    }
                    Image(uiImage:logo!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minHeight: 10, maxHeight: 80)
                }
            }
            Button(action: {
                let account = WayPay.AccountRequest(firstName: firstName, lastName: lastName, password: WayPay.Account.hashedPIN(newPIN), phone: phoneNumber, user: email)
                WayPay.Account.createAccount(account: account) { accounts, error in
                    if let accounts = accounts,
                       let account = accounts.first {
                        let merchant = WayPay.Merchant(name: businessName, email: email)
                        WayPay.Merchant.createMerchantForAccount(accountUUID: account.accountUUID, merchant: merchant, logo: logo) { merchants, error in
                            if let merchants = merchants,
                               let merchant = merchants.first {
                                WayAppUtils.Log.message("Merchant: \(merchant)")
                                DispatchQueue.main.async {
                                    session.account = account
                                    session.saveLoginData(pin: newPIN)
                                    session.merchants.setTo(merchants)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    loginError = true
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            loginError = true
                        }
                    }
                }
                
            }) {
                Text("Activate")
                    .padding()
            }
            .disabled(shouldRegistrationButtonBeDisabled)
            .buttonStyle(WayPay.WideButtonModifier())
            .animation(.easeInOut(duration: 0.3))
            .alert(isPresented: $loginError) {
                Alert(title: Text("Login error"),
                      message: Text("Email or PIN invalid. Try again. If problem persists contact support@wayapp.com"),
                      dismissButton: .default(Text("OK")))
            }
        } // Form
        .padding()
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            RegistrationView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }

    }
}
