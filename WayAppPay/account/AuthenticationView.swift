//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
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
        VStack(alignment: .center, spacing: 16.0) {
            Image("WAP-P")
                .resizable()
                .frame(width: self.imageSize, height: self.imageSize, alignment: .center)
                .scaledToFit()
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                TextField(
                    WayAppPay.session.account?.email != nil ? WayAppPay.session.account!.email! : "email"
                    , text: self.$email)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color("tertiarySystemBackgroundColor"))
                    .cornerRadius(self.textFieldcornerRadius)
                    .modifier(WayAppPay.ClearButton(text: $email))
            }
            HStack {
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                SecureField("PIN", text: self.$pin)
                    .textContentType(.password)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color("tertiarySystemBackgroundColor"))
                    .cornerRadius(self.textFieldcornerRadius)
            }
            HStack {
                Spacer()
                Button(action: {
                    self.forgotPIN = true
                }) {
                    Text("Forgot your PIN?")
                }
                .sheet(isPresented: self.$forgotPIN) {
                    EnterOTP()
                }
            }
            Button(action: {
                WayAppPay.Account.load(email: self.email.lowercased(), pin: self.pin)
            }) {
                Text("Sign in")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
            .background(shouldSigninButtonBeDisabled ? .gray : Color("WAP-GreenDark"))
            .cornerRadius(WayAppPay.UI.buttonCornerRadius)
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .animation(.easeInOut(duration: 0.3))
            .disabled(shouldSigninButtonBeDisabled)
        }
        .gesture(DragGesture().onChanged { _ in WayAppPay.hideKeyboard() })
        .padding()
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
