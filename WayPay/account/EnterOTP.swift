//
//  EnterOTP.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/9/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct EnterOTP: View {
    @EnvironmentObject private var session: WayPay.Session
    @State var otp: String = String()
    @State var otpReceived: String?
    @State var email: String = UserDefaults.standard.string(forKey: WayPay.DefaultKey.EMAIL.rawValue) ?? ""
    @State private var isAPICallOngoing = false
    @State private var showResetResultAlert = false

    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()

    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    @State private var showChangeResultAlert = false

    var shouldChangePINbuttonBeDisabled: Bool {
        return (otp.count < WayPay.Account.PINLength) ||
            (otp.count > WayPay.Account.PINLength) ||
            (otp.count == WayPay.Account.PINLength && otp != otpReceived) ||
            isAPICallOngoing ||
            !WayAppUtils.validateEmail(email)
    }

    var shouldSendEmailButtonBeDisabled: Bool {
        return isAPICallOngoing || !WayAppUtils.validateEmail(email)
    }

    private var isUserInputValid: Bool {
        return (newPIN.count == WayPay.Account.PINLength) &&
                (confirmationPIN.count == WayPay.Account.PINLength) &&
                (newPIN == confirmationPIN)
    }
        
    var shouldChangeButtonBeDisabled: Bool {
        return isAPICallOngoing || !isUserInputValid
    }

    var body: some View {
         if otpReceived == nil {
            Form {
                Text("Email new PIN to:")
                    .font(.title)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .background(Color.white)
                    .cornerRadius(WayPay.cornerRadius)
                    .padding()
                Button(action: {
                    forgotPIN()
                 }) {
                     Text("Send")
                        .padding()
                        .foregroundColor(Color.white)
                 }
                .disabled(shouldSendEmailButtonBeDisabled)
                .buttonStyle(WayPay.WideButtonModifier())
                .alert(isPresented: $showResetResultAlert) {
                    Alert(title: Text(WayPay.AlertMessage.pinChangeFailed.text.title),
                          message: Text(WayPay.AlertMessage.pinChangeFailed.text.message),
                          dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
                }
            }
        } else if otpReceived != nil && shouldChangePINbuttonBeDisabled {
            Form {
                Text("Enter OTP received:")
                    .font(.title)
                TextField("PIN", text: self.$otp)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .background(Color.white)
                    .cornerRadius(WayPay.cornerRadius)
                    .foregroundColor((otp.count == WayPay.Account.PINLength && otpReceived != otp) ||
                        otp.count > WayPay.Account.PINLength ? .red : .primary)
                    .padding()
            }
        } else {
            Form {
                Text("New PIN")
                    .font(.title)
                VStack(alignment: .trailing) {
                    HStack(alignment: .center) {
                        Text("New")
                        TextField("4-digits", text: $newPIN)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .background(Color.white)
                            .cornerRadius(WayPay.cornerRadius)
                            .padding()
                            .foregroundColor(newPIN.count > WayPay.Account.PINLength ? .red : .primary)
                    }
                    HStack(alignment: .center) {
                        Text("Re-enter")
                        TextField("4-digits", text: $confirmationPIN)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .background(Color.white)
                            .cornerRadius(WayPay.cornerRadius)
                            .padding()
                            .foregroundColor((confirmationPIN.count == WayPay.Account.PINLength && newPIN != confirmationPIN) ||
                            confirmationPIN.count > WayPay.Account.PINLength ? .red : .primary)
                    }
                }
                .padding()
                Button(action: {
                    changePIN()
                }) {
                    Text("Change")
                        .padding()
                        .foregroundColor(Color.white)
                }
                .disabled(shouldChangeButtonBeDisabled)
                .buttonStyle(WayPay.WideButtonModifier())
                .alert(isPresented: $showChangeResultAlert) {
                    Alert(title: Text(WayPay.AlertMessage.pinChangeFailed.text.title),
                          message: Text(WayPay.AlertMessage.pinChangeFailed.text.message),
                          dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
                }
            }
        }
    } // body
    
    private func forgotPIN() {
        isAPICallOngoing = true
        WayPay.Account.forgotPIN(self.email) { otps, error in
            if let otps = otps,
               let otp = otps.first {
                DispatchQueue.main.async {
                    self.otpReceived = otp.otp
                }
            } else {
                DispatchQueue.main.async {
                    self.showResetResultAlert = true
                }
            }
            DispatchQueue.main.async {
                self.isAPICallOngoing = false
            }
        }
    }
    
    private func changePIN() {
        isAPICallOngoing = true
        WayPay.Account.changePIN(self.email, newPIN: self.newPIN) { accounts, error in
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
            DispatchQueue.main.async {
                self.isAPICallOngoing = false
            }
        }
    }
}

struct EnterOTP_Previews: PreviewProvider {
    static var previews: some View {
        EnterOTP()
    }
}
