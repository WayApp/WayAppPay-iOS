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
    
    var body: some View {
        VStack {
            Image(systemName: "tortoise.fill")
            HStack {
               Image(systemName: "person.circle")
                TextField("User", text: $email).autocapitalization(.none).textContentType(.emailAddress).keyboardType(.emailAddress)
            }
            HStack {
                Image(systemName: "lock.rotation")
                TextField("Pin", text: $pin).keyboardType(.numberPad)
                HidePinView()
            }
            RememberUserView()
            ForgotPinView()
            Button(action: {

                WayAppPay.Account.load(email: self.email.lowercased(), password: self.pin)
            }) {
                Text("Start session")
            }
        }.padding()

    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
