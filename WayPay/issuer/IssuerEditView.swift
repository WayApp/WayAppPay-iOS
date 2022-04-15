//
//  IssuerEditView.swift
//  WayPay
//
//  Created by Oscar Anzola on 11/3/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct IssuerEditView: View {
    @EnvironmentObject var session: WayPayApp.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var issuer: WayPay.Issuer

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var labelColor: String = ""
    @State private var backgroundColor: String = ""
    @State private var foregroundColor: String = ""
    @State private var iconURL: String = ""
    @State private var logoURL: String = ""
    @State private var stripURL: String = ""
    @State private var error: Bool = false
    @State private var apiErrorMessage: String = ""
    
    var disableEditButton: Bool {
        return name.isEmpty || labelColor.isEmpty || foregroundColor.isEmpty || backgroundColor.isEmpty
    }
    
    var body: some View {
        List {
            Group { // Cannot edit
                VStack(alignment: .leading) {
                    Text("issuerUUID")
                        .modifier(UI.EditFieldHeader())
                    Text(issuer.issuerUUID)
                }
                VStack(alignment: .leading) {
                    Text("customerUUID")
                        .modifier(UI.EditFieldHeader())
                    Text(issuer.customerUUID ?? "-")
                }
            }
            VStack(alignment: .leading) {
                Text("name")
                    .modifier(UI.EditFieldHeader())
                TextField(issuer.name ?? "-", text: $name)
                    .textContentType(.organizationName)
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.words)
            }
            VStack(alignment: .leading) {
                Text("description")
                    .modifier(UI.EditFieldHeader())
                TextField(issuer.description ?? "-", text: $description)
                    .keyboardType(.asciiCapable)
                    .autocapitalization(.sentences)
            }
            Group { // Colors
                VStack(alignment: .leading) {
                    Text("labelColor")
                        .modifier(UI.EditFieldHeader())
                    TextField(issuer.labelColor ?? "-", text: $labelColor)
                        .keyboardType(.asciiCapable)
                        .textCase(.uppercase)
                        .foregroundColor(WayPay.Issuer.isColorFormatValid(labelColor) ? Color.primary : Color.red)
                }
                VStack(alignment: .leading) {
                    Text("backgroundColor")
                        .modifier(UI.EditFieldHeader())
                    TextField(issuer.backgroundColor ?? "-", text: $backgroundColor)
                        .keyboardType(.asciiCapable)
                        .textCase(.uppercase)
                        .foregroundColor(WayPay.Issuer.isColorFormatValid(labelColor) ? Color.primary : Color.red)
                }
                VStack(alignment: .leading) {
                    Text("foregroundColor")
                        .modifier(UI.EditFieldHeader())
                    TextField(issuer.foregroundColor ?? "-", text: $foregroundColor)
                        .keyboardType(.asciiCapable)
                        .textCase(.uppercase)
                        .foregroundColor(WayPay.Issuer.isColorFormatValid(labelColor) ? Color.primary : Color.red)
                }
            }
            Group { // Images
                VStack(alignment: .leading) {
                    Text("iconURL")
                        .modifier(UI.EditFieldHeader())
                    Text(issuer.iconURL ?? "-")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    TextEditor(text: $iconURL)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.none)
                }
                VStack(alignment: .leading) {
                    Text("logoURL")
                        .modifier(UI.EditFieldHeader())
                    Text(issuer.logoURL ?? "-")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    TextEditor(text: $logoURL)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.none)
                }
                VStack(alignment: .leading) {
                    Text("stripURL")
                        .modifier(UI.EditFieldHeader())
                    Text(issuer.stripURL ?? "-")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    TextEditor(text: $stripURL)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.none)
                }
            }

        }
        .navigationBarTitle(issuer.name ?? "-", displayMode: .inline)
        .toolbar {
            Button(LocalizedStringKey("Save")) {
                edit()
            }
            .disabled(disableEditButton)
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
    
    private func edit() {
        issuer.name = self.name
        issuer.description = self.description
        WayPay.Issuer.edit(issuer) { issuers, error in
            DispatchQueue.main.async {
                if let issuers = issuers,
                   let issuer = issuers.first,
                   let name = issuer.name {
                    Logger.message("Issuer: \(name), edited successfully")
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    Logger.message("ERROR: issuer was not edited")
                    if let error = error {
                        self.apiErrorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct IssuerEditView_Previews: PreviewProvider {
    static var previews: some View {
        Text("IssuerEditView_Previews")
    }
}
