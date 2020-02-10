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

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Enter PIN received on email:")
                .padding(.bottom, 16)
            TextField("PIN", text: $otp)
                .keyboardType(.numberPad)
                .frame(minWidth: 120, idealWidth: 120, maxWidth: 120, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
            Image("4digits")
                .frame(minWidth: 80, idealWidth: 80, maxWidth: 80, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
            Button(action: {
                // WayAppPay.Account.load(email: self.email.lowercased(), pin: self.pin)
            }) {
                Text("Confirm")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
            .background(Color(#colorLiteral(red: 0.0120000001, green: 0.4350000024, blue: 0.5649999976, alpha: 1)))
            .cornerRadius(15.0)
        }
        .padding()
    }
}

struct EnterOTP_Previews: PreviewProvider {
    static var previews: some View {
        EnterOTP()
    }
}
