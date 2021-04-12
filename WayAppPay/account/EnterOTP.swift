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
    @State var otpReceived: String?
    @State var email: String = UserDefaults.standard.string(forKey: WayAppPay.DefaultKey.EMAIL.rawValue) ?? ""
    @State private var isAPICallOngoing = false
    @State private var showResetResultAlert = false

    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()

    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    @State private var showChangeResultAlert = false

    var shouldSendEmailButtonBeDisabled: Bool {
        return isAPICallOngoing || !WayAppUtils.validateEmail(email)
    }

    var shouldChangePINbuttonBeDisabled: Bool {
        return (otp.count < WayAppPay.Account.PINLength) ||
            (otp.count > WayAppPay.Account.PINLength) ||
            (otp.count == WayAppPay.Account.PINLength && otp != otpReceived)
    }

    private func resetResult(_ otp: String?, _ error: Error?) -> Void {
        DispatchQueue.main.async {
             self.isAPICallOngoing = false
            if error != nil {
                self.showResetResultAlert = true
            } else {
                self.otpReceived = otp
            }
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
        return (newPIN.count == WayAppPay.Account.PINLength) &&
                (confirmationPIN.count == WayAppPay.Account.PINLength) &&
                (newPIN == confirmationPIN)
    }
        
    var shouldChangeButtonBeDisabled: Bool {
        return isAPICallOngoing || !isUserInputValid
    }

    var body: some View {
         if otpReceived == nil {
            return AnyView(
                VStack(alignment: .center, spacing: WayAppPay.UI.verticalSeparation) {
                    Text("Email new PIN to:")
                        .font(.title)
                    TextField("Email", text: $email)
                        .padding()
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, WayAppPay.UI.verticalSeparation)

                    Button(action: {
                        DispatchQueue.main.async {
                            self.isAPICallOngoing = true
                        }
                        WayAppPay.Account.forgotPINforEmail(self.email, completion: self.resetResult(_:_:))
                     }) {
                         Text("Send")
                             .font(.headline)
                             .fontWeight(.heavy)
                             .foregroundColor(.white)
                     }
                    .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
                    .background(shouldSendEmailButtonBeDisabled ? .gray : Color("WAP-GreenDark"))
                    .cornerRadius(WayAppPay.UI.buttonCornerRadius)
                    .padding(.bottom, keyboardObserver.keyboardHeight)
                    .disabled(shouldSendEmailButtonBeDisabled)
                }.padding()
            )
        } else if otpReceived != nil && shouldChangePINbuttonBeDisabled {
            return AnyView(
                VStack(alignment: .center, spacing: WayAppPay.UI.verticalSeparation) {
                    Text("Enter OTP received on email:")
                        .font(.headline)
                    TextField("PIN", text: self.$otp)
                        .font(.headline)
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                        .frame(width: WayAppPay.UI.pinTextFieldWidth)
                        .foregroundColor((otp.count == WayAppPay.Account.PINLength && otpReceived != otp) ||
                            otp.count > WayAppPay.Account.PINLength ? .red : .primary)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, WayAppPay.UI.verticalSeparation)
            }
            .padding())
        } else {
            return AnyView(
                VStack(alignment: .center, spacing: WayAppPay.UI.verticalSeparation) {
                    Text("New PIN")
                        .font(.title)
                        .padding(.bottom, 12)
                    VStack(alignment: .trailing, spacing: WayAppPay.UI.verticalSeparation) {
                        HStack(alignment: .center, spacing: 12) {
                            Text("New")
                            TextField("4-digits", text: $newPIN)
                                .frame(width: WayAppPay.UI.pinTextFieldWidth)
                                .foregroundColor(newPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                        }
                        HStack(alignment: .center, spacing: 12) {
                            Text("Re-enter")
                            TextField("4-digits", text: $confirmationPIN)
                                .frame(width: WayAppPay.UI.pinTextFieldWidth)
                                .foregroundColor((confirmationPIN.count == WayAppPay.Account.PINLength && newPIN != confirmationPIN) ||
                                confirmationPIN.count > WayAppPay.Account.PINLength ? .red : .primary)
                        }
                    }
                    .font(.headline)
                    .textContentType(.newPassword)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, WayAppPay.UI.verticalSeparation)

                    Button(action: {
                        DispatchQueue.main.async {
                            self.isAPICallOngoing = true
                        }
                        WayAppPay.Account.changePINforEmail(self.email, currentPIN: "1234", newPIN: self.newPIN, completion: self.changeResult(_:))
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
            )
        }
    }
}

struct EnterOTP_Previews: PreviewProvider {
    static var previews: some View {
        EnterOTP()
    }
}
