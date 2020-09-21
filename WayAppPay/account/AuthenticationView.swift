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
            Color.offWhite
            VStack(alignment: .center, spacing: 16.0) {
                Image("WAP-Logo")
                    .resizable()
                    .scaledToFit()
                HStack(spacing: 15) {
                    Image(systemName: "envelope.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                    TextField("email", text: self.$email)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
                .modifier(WayAppPay.TextFieldModifier())
                .modifier(WayAppPay.ClearButton(text: $email))
                HStack(spacing: 15) {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                    SecureField("PIN", text: self.$pin)
                        .textContentType(.password)
                        .keyboardType(.numberPad)
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
                        .foregroundColor(.black)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
                }
                /*
                .foregroundColor(.white)
                 .background(shouldSigninButtonBeDisabled ? Color.gray : Color.green)
                .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
                .cornerRadius(WayAppPay.UI.buttonCornerRadius)
    */
                .disabled(shouldSigninButtonBeDisabled)
                .buttonStyle(WayAppPay.ButtonModifier())
                .padding(.bottom, keyboardObserver.keyboardHeight - 100)
                .animation(.easeInOut(duration: 0.3))
                .alert(isPresented: $session.loginError) {
                    Alert(title: Text("Login error"),
                          message: Text("Email or PIN invalid. Try again. If problem persists contact support@wayapp.com"),
                          dismissButton: .default(Text("OK")))
                }
            } // VStack
            .gesture(DragGesture().onChanged { _ in WayAppPay.hideKeyboard() })
            .padding()

        }
        .edgesIgnoringSafeArea(.all)
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
