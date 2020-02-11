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
            print("SETTING REMEMBER")
            UserDefaults.standard.set(email, forKey: WayAppPay.DefaultKey.EMAIL.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    @State private var pin: String = ""
//    @State private var remember: Bool = UserDefaults.standard.bool(forKey:WayAppPay.DefaultKey.REMEMBER_EMAIL.rawValue) {
//        didSet {
//            print("SETTING REMEMBER")
//            UserDefaults.standard.set(remember, forKey: WayAppPay.DefaultKey.REMEMBER_EMAIL.rawValue)
//            UserDefaults.standard.synchronize()
//        }
//    }
    @State private var scrollOffset: CGSize = CGSize.zero
    @State private var forgotPIN = false

    let imageSize: CGFloat = 120.0
    let textFieldcornerRadius: CGFloat = 20.0
    
    private func keywordScrollCalculation(height: Int) -> Int {
        switch height {
        case 0..<600: return -200
        case 600..<700: return -130
        default: return 0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .center, spacing: 16.0) {
                    Spacer()
//                    Text("Geometry: width=\(Int(geometry.size.width)), height=\(Int(geometry.size.height))")
                    Image("WAP-P")
                        .resizable()
                        .frame(width: self.imageSize, height: self.imageSize, alignment: .center)
                        .scaledToFit()
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("ColorDarkText"))
                        TextField(
                            WayAppPay.session.account?.email != nil ? WayAppPay.session.account!.email! : "email"
                            , text: self.$email)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color("tertiarySystemBackgroundColor"))
                            .foregroundColor(.primary)
                            .cornerRadius(self.textFieldcornerRadius)
                            .onTapGesture {
                                if self.scrollOffset == CGSize.zero {
                                        self.scrollOffset = CGSize(width: 0, height: self.keywordScrollCalculation(height: Int(geometry.size.height)))
                                    }
                                }
                    }
                    HStack {
                        Image(systemName: "lock.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("ColorDarkText"))
                        SecureField("PIN", text: self.$pin).textContentType(.password)
                            .keyboardType(.numberPad)
                            .padding()
                            .foregroundColor(.primary)
                            .background(Color("tertiarySystemBackgroundColor"))
                            .cornerRadius(self.textFieldcornerRadius)
                            .onTapGesture {
                                if self.scrollOffset == CGSize.zero {
                                        self.scrollOffset = CGSize(width: 0, height: self.keywordScrollCalculation(height: Int(geometry.size.height)))
                                    }
                                }
                    }
//                    Toggle(isOn: self.$remember) {
//                        Text("Remember email?")
//                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            self.forgotPIN = true
                        }) {
                            Text("Forgot your PIN?")
                                .foregroundColor(Color("ColorPrimaryWp"))
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
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                    .background(Color("ColorWpGreenDark"))
                    .cornerRadius(15.0)
                    Spacer()
                }.padding()
                    .onTapGesture {
                        UIApplication.shared.keyWindow?.endEditing(true)
                        self.scrollOffset = CGSize.zero
                }
            }.offset(self.scrollOffset)
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
