//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var session: WayPayApp.Session
    @State private var email: String = UserDefaults.standard.string(forKey: WayPay.DefaultKey.EMAIL.rawValue) ?? "" {
        didSet {
            UserDefaults.standard.set(email, forKey: WayPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    @State private var pin: String = ""
    @State private var forgotPIN = false
    @State var loginError: Bool = false
    @State private var isAPICallOngoing = false
        
    private var shouldSigninButtonBeDisabled: Bool {
        return (!WayAppUtils.validateEmail(email) || pin.count != WayPay.Account.PINLength) || isAPICallOngoing
    }
    
    var body: some View {
        Form {
            HStack {
                Spacer()
                Image("WayPay-Logo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                Spacer()
            }
            TextField(NSLocalizedString("email", comment: "AuthenticationView: TextField"), text: self.$email)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
            SecureField(NSLocalizedString("4-digit PIN", comment: "AuthenticationView: TextField"), text: self.$pin)
                .textContentType(.password)
                .keyboardType(.numberPad)
            HStack {
                Spacer()
                Button(action: {
                    self.forgotPIN = true
                }) {
                    Text("Forgot PIN")
                        .foregroundColor(Color.green)
                }
                .sheet(isPresented: self.$forgotPIN) {
                    EnterOTP()
                }

            }
            .alert(isPresented: $session.showAccountHasNoMerchantsAlert) {
                Alert(title: Text(WayPay.AlertMessage.accountWithoutMerchants.text.title),
                      message: Text(WayPay.AlertMessage.accountWithoutMerchants.text.message),
                      dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
            }
            Button(action: {
                getAccount()
            }) {
                Text("Sign in")
                    .padding()
            }
            .disabled(shouldSigninButtonBeDisabled)
            .buttonStyle(UI.WideButtonModifier())
            .alert(isPresented: $loginError) {
                Alert(title: Text(WayPay.AlertMessage.loginFailed.text.title),
                      message: Text(WayPay.AlertMessage.loginFailed.text.message),
                      dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
            }
            NavigationLink(destination: MerchantRegistrationView()) {
                Text("New account")
                    .foregroundColor(Color.green)
            }
        } // Form
        .padding()
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
        .alert(isPresented: $session.showAccountPendingActivationAlert) {
            Alert(title: Text(WayPay.AlertMessage.accountPendingActivation.text.title),
                  message: Text(WayPay.AlertMessage.accountPendingActivation.text.message),
                  dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
        }
    } // body
    
    private func getAccount() {
        isAPICallOngoing = true
        WayPay.Account.load(email: self.email.lowercased(), pin: self.pin) { accounts, error in
            if let accounts = accounts,
               let account = accounts.first {
                DispatchQueue.main.async {
                    session.account = account
                    session.saveLoginData(pin: pin)
                    Logger.message("Login successful")
                }
            } else {
                DispatchQueue.main.async {
                    loginError = true
                }
            }
            DispatchQueue.main.async {
                isAPICallOngoing.toggle()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            AuthenticationView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }

    }
}
