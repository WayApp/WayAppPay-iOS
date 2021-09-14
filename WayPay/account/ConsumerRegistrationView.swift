//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ConsumerRegistrationView: View {
    @EnvironmentObject private var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var email: String = String(){
        didSet {
            UserDefaults.standard.set(email, forKey: WayPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    @State private var name = String()
    @State private var isAPICallOngoing = false
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
    @State var showAccountCreationAlert: Bool = false
    @State var wasAccountCreatedSuccessfully: Bool = false

    private var shouldRegistrationButtonBeDisabled: Bool {
        return !WayAppUtils.validateEmail(email) || name.isEmpty || isAPICallOngoing
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
            Section(header: Label(NSLocalizedString("Customer", comment: "SettingsView: section title"), systemImage: "person.fill")
                        .accessibility(label: Text("Customer"))
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
            }
            Button(action: {
                isAPICallOngoing = true
                let account = WayPay.AccountRequest(firstName: firstName, lastName: lastName, password: WayPay.Account.hashedPIN("4762"), phone: "123456789", user: email)
                WayPay.Account.createAccount(account: account) { accounts, error in
                    if let accounts = accounts,
                       !accounts.isEmpty {
                        DispatchQueue.main.async {
                            wasAccountCreatedSuccessfully = true
                            showAccountCreationAlert = true
                            isAPICallOngoing = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            wasAccountCreatedSuccessfully = false
                            showAccountCreationAlert = true
                            isAPICallOngoing = false
                        }
                    }
                }
            }) {
                Text("Register")
                    .padding()
            }
            .disabled(shouldRegistrationButtonBeDisabled)
            .buttonStyle(WayPay.WideButtonModifier())
            .animation(.easeInOut(duration: 0.3))
            .alert(isPresented: $showAccountCreationAlert) {
                Alert(title: Text(wasAccountCreatedSuccessfully ?
                                    WayPay.AlertMessage.consumerAccountCreationSuccess.text.title :
                                    WayPay.AlertMessage.consumerAccountCreationError.text.title),
                      message: Text(wasAccountCreatedSuccessfully ?
                                    WayPay.AlertMessage.consumerAccountCreationSuccess.text.message :
                                    WayPay.AlertMessage.consumerAccountCreationError.text.message),
                      dismissButton: .default(Text(WayPay.SingleMessage.OK.text), action: {
                        if wasAccountCreatedSuccessfully {
                            self.presentationMode.wrappedValue.dismiss()
                        } })
                )
            }
        } // Form
        .padding()
    }
}

struct ConsumerView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            MerchantRegistrationView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }

    }
}
