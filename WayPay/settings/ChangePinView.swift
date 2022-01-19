//
//  ChangePinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/7/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ChangePinView: View {
    @EnvironmentObject private var session: WayPayApp.Session
    @State private var currentPIN = String()
    let savedPIN: String?
    let email: String?
    
    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    @State private var isAPICallOngoing = false

    @State private var showChangeResultAlert = false

    @SwiftUI.Environment(\.presentationMode) var presentationMode

    @ObservedObject private var keyboardObserver = UI.KeyboardObserver()
    
    init() {
        if let account = WayPayApp.session.account,
            let email = account.email,
            let savedPIN = WayPay.Account.retrievePassword(forEmail: email) {
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
                (newPIN == confirmationPIN) &&
                (newPIN != currentPIN)
    }
    
    var isCurrentPINValid: Bool {
        if currentPIN.count == WayPay.Account.PINLength {
            return savedPIN == currentPIN
        } else  {
            return false
        }
    }
    
    var shouldChangeButtonBeDisabled: Bool {
        return isAPICallOngoing || !isUserInputValid
    }
    
    var body: some View {
        Form {
           Text("Change PIN")
               .font(.title)
           VStack(alignment: .trailing) {
               HStack(alignment: .center) {
                   Text("Current")
                   TextField(NSLocalizedString("4-digits", comment: "ChangePinView: TextField"), text: $currentPIN)
                       .textContentType(.oneTimeCode)
                       .keyboardType(.numberPad)
                       .background(Color.white)
                       .cornerRadius(UI.Constant.cornerRadius)
                       .padding()
                    .foregroundColor(isCurrentPINValid ? .primary : .red)
               }
               HStack(alignment: .center) {
                   Text("New")
                   TextField(NSLocalizedString("4-digits", comment: "ChangePinView: TextField"), text: $newPIN)
                       .textContentType(.oneTimeCode)
                       .keyboardType(.numberPad)
                       .background(Color.white)
                       .cornerRadius(UI.Constant.cornerRadius)
                       .padding()
                       .foregroundColor(newPIN.count != WayPay.Account.PINLength ? .red : .primary)
               }
               HStack(alignment: .center) {
                   Text("Re-enter")
                   TextField(NSLocalizedString("4-digits", comment: "ChangePinView: TextField"), text: $confirmationPIN)
                       .textContentType(.oneTimeCode)
                       .keyboardType(.numberPad)
                       .background(Color.white)
                       .cornerRadius(UI.Constant.cornerRadius)
                       .padding()
                       .foregroundColor(newPIN != confirmationPIN ? .red : .primary)
               }
           }
           .textFieldStyle(RoundedBorderTextFieldStyle())
           .padding()
           Button(action: {
               if let email = self.email {
                   DispatchQueue.main.async {
                       self.isAPICallOngoing = true
                   }
                   WayPay.Account.changePIN(email, newPIN: self.newPIN) { accounts, error in
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
           }
           .disabled(shouldChangeButtonBeDisabled)
           .buttonStyle(UI.WideButtonModifier())
           .alert(isPresented: $showChangeResultAlert) {
               Alert(title: Text("System error"),
                     message: Text("PIN could not be changed. Try again later. If problem persists contact support@wayapp.com"),
                     dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
           }
       } // VStack
    }
}

struct ChangePinView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePinView()
    }
}
