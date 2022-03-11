//
//  SepaView.swift
//  WayPay
//
//  Created by Oscar Anzola on 11/3/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct SepaView: View {
    var issuer: WayPay.Issuer
    @State private var from: Date = Date()
    @State private var to: Date = Date()

    var body: some View {
        Form {
            DatePicker(selection: $from, displayedComponents: .date) {
                Text("From")
            }
            DatePicker(selection: $to, displayedComponents: .date) {
                Text("To")
            }
            Button {
                Logger.message("Get SEPA")
            } label: {
                Text("Generate SEPA")
                    .padding()
            }
            .buttonStyle(UI.WideButtonModifier())
            Button(action: {
                Logger.message("Cancel")
            }) {
                Text("Cancel")
                    .padding()
            }
            .buttonStyle(UI.CancelButtonModifier())
        }
        .navigationTitle(issuer.name ?? "Name")
    }
}

struct SepaView_Previews: PreviewProvider {
    static var previews: some View {
        Text("SEPA")
    }
}
