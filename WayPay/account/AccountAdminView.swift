//
//  AccountAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct AccountAdminView: View {
    var account: WayPay.Account

    var body: some View {
        List {
            NavigationLink(destination: CardsView()) {
                Label("QRs", systemImage: "qrcode")
            }
        }.navigationBarTitle(account.email ?? "", displayMode: .inline)
    }
}

struct AccountAdminView_Previews: PreviewProvider {
    static var previews: some View {
        Text("AccountAdminView_Previews")
    }
}

extension AccountAdminView {
    private func registerAccount() {
        WayPay.Account.register(registration:
                                    WayPay.Registration(email: "o2@wayapp.com", issuerUUID: "65345945-0e04-47b2-ae08-c5e7022a71aa")) { registrations, error in
            if let registrations = registrations,
               let registration = registrations.first {
                Logger.message("Registration: \(registration)")
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Registration ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Registration ERROR: -------------")
            }
        }

    }
}
