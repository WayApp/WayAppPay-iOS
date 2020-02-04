//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    @State var email: String = ""
    @State var pin: String = ""
    @State var remember: Bool = true

    let imageSize: CGFloat = 120.0
    let textFieldcornerRadius: CGFloat = 20.0
    
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            Image("WAP-P")
                .resizable()
                .frame(width: imageSize, height: imageSize, alignment: .center)
                .scaledToFit()
            HStack {
                Image(systemName: "person.circle")
                TextField("User", text: $email).autocapitalization(.none).textContentType(.emailAddress).keyboardType(.emailAddress)
                    .padding()
                    .background(Color("tertiarySystemBackgroundColor"))
                    .foregroundColor(.primary)
                    .cornerRadius(textFieldcornerRadius)
            }
            HStack {
                Image(systemName: "lock.rotation")
                SecureField("PIN", text: $pin).keyboardType(.numberPad)
                    .padding()
                    .foregroundColor(.primary)
                    .background(Color("tertiarySystemBackgroundColor"))
                    .cornerRadius(textFieldcornerRadius)
            }
            HStack {
                Spacer()
                Toggle(isOn: $remember) {
                    Text("Remember email?")
                }
            }
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Text("Forgot your PIN?")
                    .foregroundColor(Color("link"))
            }
            Button(action: {
                WayAppPay.Account.load(email: self.email.lowercased(), password: self.pin)
            }) {
                Text("Sign in")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
            .background(Color("WAP-Blue"))
            .cornerRadius(15.0)
            Spacer()
        }.padding()

    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
