//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var session: WayPay.Session
    @State private var email: String = UserDefaults.standard.string(forKey: WayPay.DefaultKey.EMAIL.rawValue) ?? "" {
        didSet {
            UserDefaults.standard.set(email, forKey: WayPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    @State private var pin: String = ""
    @State private var forgotPIN = false
    @State var loginError: Bool = false

        
    private var shouldSigninButtonBeDisabled: Bool {
        return (!WayAppUtils.validateEmail(email) || pin.count != WayPay.Account.PINLength)
    }
    
    var body: some View {
        VStack() {
            Text("")
                .padding(.bottom,100)
            Image("WayPay-Logo")
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
            Form {
                TextField("Email", text: self.$email)
                    .font(.title3)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                SecureField("PIN", text: self.$pin)
                    .font(.title3)
                    .frame(width: 100)
                    .textContentType(.password)
                    .keyboardType(.numberPad)
                Button(action: {
                    WayPay.Account.load(email: self.email.lowercased(), pin: self.pin) { accounts, error in
                        if let accounts = accounts,
                           let account = accounts.first {
                            DispatchQueue.main.async {
                                session.account = account
                                session.saveLoginData(pin: pin)
                            }
                        } else {
                            DispatchQueue.main.async {
                                loginError = true
                            }
                        }
                    }
                }) {
                    Text("Sign in")
                        .padding()
                }
                .disabled(shouldSigninButtonBeDisabled)
                .buttonStyle(WayPay.WideButtonModifier())
                .animation(.easeInOut(duration: 0.3))
                .alert(isPresented: $loginError) {
                    Alert(title: Text("Login error"),
                          message: Text("Email or PIN invalid. Try again. If problem persists contact support@wayapp.com"),
                          dismissButton: .default(Text("OK")))
                }
                HStack {
                    Button(action: {
                        self.forgotPIN = true
                    }) {
                        Text("Register")
                            .bold()
                            .foregroundColor(Color("MintGreen"))
                    }
                    .sheet(isPresented: self.$forgotPIN) {
                        EnterOTP()
                    }
                    Spacer()
                    Button(action: {
                        self.forgotPIN = true
                    }) {
                        Text("Forgot PIN")
                            .bold()
                            .foregroundColor(Color("MintGreen"))
                    }
                    .sheet(isPresented: self.$forgotPIN) {
                        EnterOTP()
                    }
                } // HStack
            } // Form
            .padding()
        } // VStack
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
