//
//  NewIssuerView.swift
//  WayPay
//
//  Created by Oscar Anzola on 14/4/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct NewIssuerView: View {
    @EnvironmentObject var session: WayPayApp.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var customer: WayPay.Customer
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var labelColor: String = ""
    @State private var backgroundColor: String = ""
    @State private var foregroundColor: String = ""
    @State private var error: Bool = false
    @State private var apiErrorMessage: String = ""
    
    var disableCreateButton: Bool {
        return name.isEmpty
        || !WayPay.Issuer.isColorFormatValid(labelColor)
        || !WayPay.Issuer.isColorFormatValid(backgroundColor)
        || !WayPay.Issuer.isColorFormatValid(foregroundColor)
    }
    
    var body: some View {
        Form {
            TextField("name", text: $name)
                .textContentType(.organizationName)
                .keyboardType(.asciiCapable)
                .autocapitalization(.words)
            TextField("description", text: $description)
                .keyboardType(.asciiCapable)
                .autocapitalization(.sentences)
            TextField("labelColor (#1C1C1C)", text: $labelColor)
                .keyboardType(.asciiCapable)
                .foregroundColor(WayPay.Issuer.isColorFormatValid(labelColor) ? Color.primary : Color.red)
            TextField("backgroundColor (#0DB774)", text: $backgroundColor)
                .keyboardType(.asciiCapable)
                .foregroundColor(WayPay.Issuer.isColorFormatValid(backgroundColor) ? Color.primary : Color.red)
            TextField("foregroundColor (#FFFFFF)", text: $foregroundColor)
                .keyboardType(.asciiCapable)
                .foregroundColor(WayPay.Issuer.isColorFormatValid(foregroundColor) ? Color.primary : Color.red)
        }
        .navigationBarTitle(Text("New Issuer"), displayMode: .inline)
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
        let issuer = WayPay.Issuer(customerUUID: customer.customerUUID, name: name, description: description, labelColor: labelColor.uppercased(), backgroundColor: backgroundColor.uppercased(), foregroundColor: foregroundColor.uppercased())
        WayPay.Issuer.create(issuer) { issuers, error in
            DispatchQueue.main.async {
                if let issuers = issuers,
                   let issuer = issuers.first,
                   let name = issuer.name {
                    Logger.message("Issuer: \(name), created successfully")
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    Logger.message("ERROR: issuer was not created")
                    self.apiErrorMessage = error?.localizedDescription ?? "Issuer was not created"
                    self.error = true
                }
            }
        }
    }
}

struct NewIssuerView_Previews: PreviewProvider {
    static var previews: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
