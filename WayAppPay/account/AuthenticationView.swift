//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @State private var email: String = UserDefaults.standard.string(forKey: WayAppPay.DefaultKey.EMAIL.rawValue) ?? "" {
        didSet {
            UserDefaults.standard.set(email, forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    @State private var pin: String = ""
    @State private var forgotPIN = false
    
    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()
    
    private let imageSize: CGFloat = 120.0
    private let textFieldcornerRadius: CGFloat = 20.0
    
    private var shouldSigninButtonBeDisabled: Bool {
        return (!WayAppUtils.validateEmail(email) || pin.count != WayAppPay.Account.PINLength)
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image("WAP-Logo")
                    .resizable()
                    .scaledToFit()
                HStack() {
                    Image(systemName: "envelope.circle.fill")
                        .resizable()
                        .foregroundColor(Color("WAP-Blue"))
                        .frame(width: 30, height: 30)
                    TextField("email", text: self.$email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .modifier(WayAppPay.TextFieldModifier())
                .modifier(WayAppPay.ClearButton(text: $email))
                HStack() {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .foregroundColor(Color("WAP-Blue"))
                        .frame(width: 30, height: 30)
                    SecureField("PIN", text: self.$pin)
                        .textContentType(.password)
                        .keyboardType(.numberPad)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .modifier(WayAppPay.TextFieldModifier())
                .modifier(WayAppPay.ClearButton(text: $pin))
                HStack {
                    Spacer()
                    Button(action: {
                        self.forgotPIN = true
                    }) {
                        Text("Forgot PIN?")
                    }
                    .sheet(isPresented: self.$forgotPIN) {
                        EnterOTP()
                    }
                }
                Button(action: {
                    WayAppPay.Account.load(email: self.email.lowercased(), pin: self.pin)
                }) {
                    Text("Sign in")
                        .padding(.vertical)
                        .foregroundColor(Color.white)
                        .font(.title2)
                        .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
                }
                .disabled(shouldSigninButtonBeDisabled)
                .buttonStyle(WayAppPay.ButtonModifier())
                .animation(.easeInOut(duration: 0.3))
                .alert(isPresented: $session.loginError) {
                    Alert(title: Text("Login error"),
                          message: Text("Email or PIN invalid. Try again. If problem persists contact support@wayapp.com"),
                          dismissButton: .default(Text("OK")))
                }
            } // VStack
            .padding()
        }
        .onTapGesture { hideKeyboard() }
        .background(
            Image("WAP-Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        )
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
