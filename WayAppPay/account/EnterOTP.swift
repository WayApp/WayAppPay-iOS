//
//  EnterOTP.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/9/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct EnterOTP: View {
    @State var otp: String = String()
    @State var emailSent: Bool = true
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    
    let textFieldcornerRadius: CGFloat = 20.0

    var body: some View {
        if emailSent {
            return AnyView(
                VStack(alignment: .center, spacing: 0) {
                    Text("Enter PIN received on email:")
                        .bold()
                        .padding(.bottom, 16)
                    SecureField("PIN", text: self.$otp).textContentType(.password)
                        .keyboardType(.numberPad)
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color("tertiarySystemBackgroundColor"))
                        .cornerRadius(self.textFieldcornerRadius)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 60)
//                    TextField("PIN", text: $otp)
//                        .keyboardType(.numberPad)
//                        .frame(minWidth: 120, idealWidth: 120, maxWidth: 120, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
//                        .font(.system(size: 48, weight: .bold, design: .monospaced))
//                    Image("4digits")
//                        .frame(minWidth: 80, idealWidth: 80, maxWidth: 80, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    Button(action: {
                        // WayAppPay.Account.load(email: self.email.lowercased(), pin: self.pin)
                    }) {
                        Text("Confirm")
                    }
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                    .background(Color("ColorWpGreenDark"))
                    .cornerRadius(self.textFieldcornerRadius)
            }
            .padding())
        } else {
            return AnyView(
                VStack(alignment: .center, spacing: 16) {
                    Text("Recover PIN")
                        .font(.largeTitle)
                        .bold()
                    TextField("Email", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                        .padding()
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .background(Color("tertiarySystemBackgroundColor"))
                        .foregroundColor(.primary)
                        .cornerRadius(self.textFieldcornerRadius)
                    Text("Send pin to your email")
                    HStack(alignment: .center, spacing: 24) {
//                        Button(action: {
//                            self.presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Text("Cancel")
//                        }
                        Button(action: {
                            self.emailSent = true
                        }) {
                            Text("Accept")
                                .padding()
                                .background(Color("ColorWpGreenDark"))
                                .foregroundColor(Color.white)
                                .cornerRadius(self.textFieldcornerRadius)
                        }
                    }
                }.padding()
            )
        }
    }
}

struct EnterOTP_Previews: PreviewProvider {
    static var previews: some View {
        EnterOTP()
    }
}
