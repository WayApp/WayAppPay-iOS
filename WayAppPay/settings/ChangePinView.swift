//
//  ChangePinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/7/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ChangePinView: View {
    @State private var currentPIN = String()
    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    
    let textFieldcornerRadius: CGFloat = 6.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Change PIN")
                .font(.largeTitle)
                .padding(.bottom, 16)
            Divider()
            HStack {
                Text("Current")
                    .frame(width: 120)
                TextField(" PIN", text: $currentPIN)
                    .frame(minWidth: 120, idealWidth: 120, maxWidth: 120, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                .keyboardType(.numberPad)
                .foregroundColor(.primary)
                .background(Color("tertiarySystemBackgroundColor"))
                .cornerRadius(self.textFieldcornerRadius)
            }
            Divider()
            HStack {
                Text("New")
                    .frame(width: 120)
                TextField(" PIN", text: $newPIN)
                    .frame(minWidth: 120, idealWidth: 120, maxWidth: 120, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                .keyboardType(.numberPad)
                .foregroundColor(.primary)
                .background(Color("tertiarySystemBackgroundColor"))
                .cornerRadius(self.textFieldcornerRadius)
            }
            HStack {
                Text("Re-enter")
                    .frame(width: 120)
                TextField(" PIN", text: $confirmationPIN)
                    .frame(minWidth: 120, idealWidth: 120, maxWidth: 120, minHeight: 40, idealHeight: 40, maxHeight: 40, alignment: .center)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                .keyboardType(.numberPad)
                .foregroundColor(.primary)
                .background(Color("tertiarySystemBackgroundColor"))
                .cornerRadius(self.textFieldcornerRadius)
            }
            Divider()
                .padding(.bottom, 32)
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
        .foregroundColor(Color.black)
    }
}

struct ChangePinView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePinView()
    }
}
