//
//  NewAccountView.swift
//  WayPay
//
//  Created by Oscar Anzola on 14/4/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct NewAccountView: View {
    @EnvironmentObject var session: WayPayApp.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var email: String = ""
    @State private var pin: String = ""
    @State private var phone: String = ""
    @State private var format: WayPay.Account.Format = .MERCHANT
    @State private var error: Bool = false
    @State private var apiErrorMessage: String = ""
    
    var disableCreateButton: Bool {
        return email.isEmpty || (pin.count != 4)
    }
    
    var body: some View {
        Form {
            TextField("first name", text: $firstname)
                .textContentType(.givenName)
                .keyboardType(.asciiCapable)
                .autocapitalization(.words)
            TextField("last name", text: $lastname)
                .textContentType(.familyName)
                .keyboardType(.asciiCapable)
                .autocapitalization(.words)
            TextField("email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            TextField("PIN", text: $pin)
                .textContentType(.newPassword)
                .keyboardType(.numberPad)
            TextField("phone", text: $phone)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
            Picker(selection: $format, label: Text("Format")) {
                ForEach(WayPay.Account.Format.allCases, id: \.self) { format in
                    Text(format.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

        }
        .navigationBarTitle(Text("New Account"), displayMode: .inline)
        .toolbar {
            Button(LocalizedStringKey("Create")) {
                create()
            }
            .disabled(disableCreateButton)
        }
        .alert(isPresented: $error) {
            Alert(
                title: Text(WayPay.SingleMessage.apiErrorAlertTitle.text)
                    .font(.title),
                message: Text(apiErrorMessage),
                dismissButton: .default(
                    Text(WayPay.SingleMessage.OK.text))
            )
        }
    }
    
    private func create() {
        let accountRequest = WayPay.AccountRequest(firstName: firstname, lastName: lastname, password: pin, phone: phone, user: email, format: format)
        WayPay.Account.create(accountRequest) { accounts, error in
            DispatchQueue.main.async {
                if let accounts = accounts,
                   let account = accounts.first,
                   let email = account.email {
                    Logger.message("Account: \(email), created successfully")
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    Logger.message("ERROR: account was not created")
                    if let error = error {
                        self.apiErrorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

}

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
