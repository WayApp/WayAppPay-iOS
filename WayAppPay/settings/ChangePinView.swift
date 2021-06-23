//
//  ChangePinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/7/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ChangePinView: View {
    @EnvironmentObject private var session: WayAppPay.Session
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
        ZStack {
            Color("CornSilk")
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Text("Change PIN")
                    .font(.title)
                VStack(alignment: .trailing) {
                    HStack(alignment: .center) {
                        Text("Current")
                        TextField("4-digits", text: $currentPIN)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .background(Color.white)
                            .cornerRadius(WayAppPay.cornerRadius)
                            .padding()
                            .foregroundColor((newPIN.count == WayAppPay.Account.PINLength && newPIN == currentPIN) ||
                            newPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                    }
                    HStack(alignment: .center) {
                        Text("New")
                        TextField("4-digits", text: $newPIN)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .background(Color.white)
                            .cornerRadius(WayAppPay.cornerRadius)
                            .padding()
                            .foregroundColor((newPIN.count == WayAppPay.Account.PINLength && newPIN == currentPIN) ||
                            newPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                    }
                    HStack(alignment: .center) {
                        Text("Re-enter")
                        TextField("4-digits", text: $confirmationPIN)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .background(Color.white)
                            .cornerRadius(WayAppPay.cornerRadius)
                            .padding()
                            .foregroundColor((confirmationPIN.count == WayAppPay.Account.PINLength && newPIN != confirmationPIN) ||
                            confirmationPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                    }
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                Button(action: {
                    if let email = self.email {
                        DispatchQueue.main.async {
                            self.isAPICallOngoing = true
                        }
                        WayAppPay.Account.changePIN(email, newPIN: self.newPIN) { accounts, error in
                            DispatchQueue.main.async {
                                self.isAPICallOngoing = false
                            }
                            if let accounts = accounts,
                               let account = accounts.first {
                                DispatchQueue.main.async {
                                    session.account = account
                                    session.saveLoginData(pin: newPIN)
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.showChangeResultAlert = true
                                }
                            }
                        }
                    }
                }) {
                    Text("Change")
                        .padding()
                        .foregroundColor(Color.white)
                }
                .disabled(shouldChangeButtonBeDisabled)
                .buttonStyle(WayAppPay.ButtonModifier())
                .alert(isPresented: $showChangeResultAlert) {
                    Alert(title: Text("System error"),
                          message: Text("PIN could not be changed. Try again later. If problem persists contact support@wayapp.com"),
                          dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}

struct ChangePinView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePinView()
    }
}
