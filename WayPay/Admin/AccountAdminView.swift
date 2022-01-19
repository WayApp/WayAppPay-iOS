//
//  AccountAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct AccountAdminView: View {
    var body: some View {
        Form {
            Button {
                DispatchQueue.main.async {
                    self.registerAccount()
                }
            } label: {
                Label("Register account", systemImage: "arrow.up.and.person.rectangle.portrait")
            }
            Button {
                DispatchQueue.main.async {
                    self.deleteAccount()
                }
            } label: {
                Label("Delete account", systemImage: "trash")
            }

        }.navigationBarTitle(Text("Account"), displayMode: .inline)
    }
}

struct AccountAdminView_Previews: PreviewProvider {
    static var previews: some View {
        AccountAdminView()
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
    
    private func deleteAccount() {
        WayPay.Account.delete("6fa34db2-6b03-4373-81ae-7ab1d8d22998")
        WayPay.Account.delete("a6474661-99bd-43fb-be67-a0372fd6c9e9")
    }


}
