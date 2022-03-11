//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct MerchantRegistrationView: View {
    @EnvironmentObject private var session: WayPayApp.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
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
    @State var registrationError: Bool = false
    @State var registrationSuccess: Bool = false
    @State private var businessName = String()
    @State private var registrationCode = String()
    @State private var phoneNumber = String()
    @State private var logo: UIImage? = UIImage(named: WayPay.Merchant.defaultLogo)
    @State private var showImagePicker: Bool = false
    @State private var isAPIcalled: Bool = false

    private var shouldRegistrationButtonBeDisabled: Bool {
        return (!WayAppUtils.validateEmail(email) || newPIN.count != WayPay.Account.PINLength) || businessName.isEmpty || registrationCode.count < WayPay.Merchant.minimumRegistrationCodeLength || isAPIcalled
    }
    
    var body: some View {
        Form {
            Section(header: Label(NSLocalizedString("My account", comment: "MerchantRegistrationView: section title"), systemImage: "person.fill")
                        .accessibility(label: Text("My account"))
                        .font(.callout)) {
                TextField(NSLocalizedString("name", comment: "MerchantRegistrationView: TextField"), text: self.$name)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .textContentType(.name)
                TextField(NSLocalizedString("email address", comment: "MerchantRegistrationView: TextField"), text: self.$email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                TextField(NSLocalizedString("4-digit PIN", comment: "MerchantRegistrationView: TextField"), text: self.$newPIN)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .foregroundColor((newPIN.count == WayPay.Account.PINLength) ? .primary : .red)
                TextField(NSLocalizedString("confirm PIN", comment: "MerchantRegistrationView: TextField"), text: self.$confirmationPIN)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .foregroundColor((confirmationPIN.count == WayPay.Account.PINLength && newPIN == confirmationPIN) ? .primary : .red)
            }
            Section(header:
                        Label(NSLocalizedString("My business", comment: "SettingsView: section title"), systemImage: "greetingcard.fill")
                        .font(.callout)) {
                TextField(NSLocalizedString("business name", comment: "MerchantRegistrationView: TextField"), text: self.$businessName)
                    .disableAutocorrection(true)
                    .textContentType(.organizationName)
                TextField(NSLocalizedString("phone number", comment: "MerchantRegistrationView: TextField"), text: self.$phoneNumber)
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
                            PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$logo) { }
                        }
                    Image(uiImage:logo!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minHeight: 10, maxHeight: 80)
                }
            }
            Section(header:
                        Label(NSLocalizedString("My community", comment: "SettingsView: section title"), systemImage: "building.2.fill")
                        .font(.callout)) {
                TextField(NSLocalizedString("community id", comment: "MerchantRegistrationView: TextField"), text: self.$registrationCode)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textContentType(.oneTimeCode)
            }
            Button(action: {
                isAPIcalled = true
                let accountRequest = WayPay.AccountRequest(firstName: firstName, lastName: lastName, password: WayPay.Account.hashedPIN(newPIN), phone: phoneNumber, user: email)
                let merchant = WayPay.Merchant(name: businessName, email: email, registrationCode: registrationCode)
                WayPay.Merchant.createAccountAndMerchant(accountRequest: accountRequest, merchant: merchant, logo: logo) { merchants, error in
                    isAPIcalled = false
                    if let merchants = merchants,
                       let merchant = merchants.first {
                        Logger.message("Merchant: \(merchant)")
                        DispatchQueue.main.async {
                            registrationSuccess = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            registrationError = true
                        }
                    }
                }
            }) {
                Text("Request activation")
                    .padding()
            }
            .disabled(shouldRegistrationButtonBeDisabled)
            .buttonStyle(UI.WideButtonModifier())
            .alert(isPresented: $registrationError) {
                Alert(title: Text("Registration error"),
                      message: Text("Check the community ID and and try again. Your account may already exist. If problem continues contact support@wayapp.com"),
                      dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
            }
        } // Form
        .navigationBarTitle(Text("Registration"), displayMode: .inline)
        .alert(isPresented: $registrationSuccess) {
            Alert(title: Text("Registration success"),
                  message: Text("Almost set! You will be contacted by WayPay to get your bank account information"),
                  dismissButton: .default(Text(WayPay.SingleMessage.OK.text), action: {
                self.presentationMode.wrappedValue.dismiss() })
            )
        }
        .padding()
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            MerchantRegistrationView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        
    }
}
