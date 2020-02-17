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
    let savedPIN: String?
    let email: String?
    
    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    @State private var isAPICallOngoing = false

    @State private var showChangeResultAlert = false

    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()
    
    init() {
        if let account = WayAppPay.session.account,
            let email = account.email,
            let savedPIN = WayAppPay.Account.retrievePassword(forEmail: email) {
            self.email = email
            self.savedPIN = savedPIN
        } else {
            self.savedPIN = nil
            self.email = nil
        }
    }
    
    private func changeResult(_ error: Error?) {
        DispatchQueue.main.async {
            self.isAPICallOngoing = false
            if error != nil {
                self.showChangeResultAlert = true
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var isUserInputValid: Bool {
        return isCurrentPINValid &&
                (newPIN.count == WayAppPay.Account.PINLength) &&
                (confirmationPIN.count == WayAppPay.Account.PINLength) &&
                (newPIN == confirmationPIN) &&
                (newPIN != currentPIN)
    }
    
    var isCurrentPINValid: Bool {
        if currentPIN.count == WayAppPay.Account.PINLength {
            return savedPIN == currentPIN
        } else  {
            return false
        }
    }
    
    var shouldChangeButtonBeDisabled: Bool {
        return isAPICallOngoing || !isUserInputValid
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: WayAppPay.UI.verticalSeparation) {
            Text("Change PIN")
                .font(.title)
                .padding(.bottom, 12)
            VStack(alignment: .trailing, spacing: WayAppPay.UI.verticalSeparation) {
                HStack(alignment: .center, spacing: 12) {
                    Text("Current")
                    TextField("4-digits", text: $currentPIN)
                        .textContentType(.password)
                        .frame(width: WayAppPay.UI.pinTextFieldWidth)
                        .foregroundColor((currentPIN.count == WayAppPay.Account.PINLength && savedPIN != currentPIN) ||
                        currentPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                }
                HStack(alignment: .center, spacing: 12) {
                    Text("New")
                    TextField("4-digits", text: $newPIN)
                        .textContentType(.newPassword)
                        .frame(width: WayAppPay.UI.pinTextFieldWidth)
                        .foregroundColor((newPIN.count == WayAppPay.Account.PINLength && newPIN == currentPIN) ||
                        newPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                }
                HStack(alignment: .center, spacing: 12) {
                    Text("Re-enter")
                    TextField("4-digits", text: $confirmationPIN)
                        .textContentType(.newPassword)
                        .frame(width: WayAppPay.UI.pinTextFieldWidth)
                        .foregroundColor((confirmationPIN.count == WayAppPay.Account.PINLength && newPIN != confirmationPIN) ||
                        confirmationPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                }
            }
            .font(.headline)
            .keyboardType(.numberPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.bottom, WayAppPay.UI.verticalSeparation)

            Button(action: {
                if let email = self.email {
                    DispatchQueue.main.async {
                        self.isAPICallOngoing = true
                    }
                    WayAppPay.Account.changePINforEmail(email, currentPIN: self.currentPIN, newPIN: self.newPIN, completion: self.changeResult(_:))
                }
            }) {
                Text("Change")
                    .font(.headline)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
            .background(shouldChangeButtonBeDisabled ? .gray : Color("WAP-GreenDark"))
            .cornerRadius(WayAppPay.UI.buttonCornerRadius)
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .disabled(shouldChangeButtonBeDisabled)
            .alert(isPresented: $showChangeResultAlert) {
                Alert(title: Text("System error"),
                      message: Text("PIN could not be changed. Try again later. If problem persists contact support@wayapp.com"),
                      dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}

struct ChangePinView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePinView()
    }
}
