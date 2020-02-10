//
//  SettingsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

extension String: ContainerProtocol {
    var containerID: String {
        return self
    }
}

struct SettingsView: View {
    @EnvironmentObject var session: WayAppPay.Session
    @State private var changePIN = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Operating merchant")) {
                    if session.merchants.isEmpty {
                        Text("There are no merchants")
                    } else {
                        Picker(selection: $session.seletectedMerchant, label: Text("Merchant")) {
                            ForEach(0..<session.merchants.count) {
                                Text(self.session.merchants[$0].name ?? "SILVANA")
                            }
                        }
                    }
                }
                Section(header: Text("Accounts")) {
                    if session.accounts.isEmpty {
                        Text("There are no accounts")
                    } else {
                        Picker(selection: $session.selectedAccount, label: Text("Account")) {
                            ForEach(0..<session.accounts.count) {
                                Text(self.session.accounts[$0].email ?? "no email")
                            }
                        }
                    }
                }
                Section(header: Text("Account: \(session.account?.email ?? "no email")")) {
                    VStack {
                        Button(action: {
                            self.changePIN = true
                        }) {
                            Text("Change PIN")
                        }
                        .sheet(isPresented: self.$changePIN) {
                            ChangePinView()
                        }

                    }
                    Button(action: {
                        DispatchQueue.main.async {
                            self.session.logout()
                        }
                    }) {
                        Text("Logout")
                    }
                }
            }.navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
