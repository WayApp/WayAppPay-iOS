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
    @State private var showBankAuthenticationView = false
    @State private var authURL: String? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Operating merchant")) {
                    if session.merchants.isEmpty {
                        Text("There are no merchants")
                    } else {
                        Picker(selection: $session.seletectedMerchant, label: Text("Merchant")) {
                            ForEach(0..<session.merchants.count) {
                                Text(self.session.merchants[$0].name ?? "NAME")
                            }
                        }
                    }
                }
                Section(header: Text("Accounts")) {
                    if WayAppPay.session.accounts.isEmpty {
                        Text("There are no accounts")
                    } else {
                        Picker(selection: $session.selectedAccount, label: Text("Account")) {
                            ForEach(0..<WayAppPay.session.accounts.count) {
                                Text(WayAppPay.session.accounts[$0].email ?? "no email")
                            }
                        }
                    }
                }
                .onAppear(perform:
                            {
                                WayAppUtils.Log.message("+++++++++++ ACCOUNTS COUNT=\(WayAppPay.session.accounts.count)")
                            })
                Section(header: Text("Account: \(WayAppPay.session.account?.email ?? "no email")")) {
                    /*
                    if session.doesUserHasMerchantAccount {
                        NavigationLink(
                            destination: CardsView()
                        ) {
                            Text("Payment token")
                        }
                    }
 */
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
                            WayAppPay.session.accounts.empty()
                            WayAppPay.session.account?.email = ""
                        }
                    }) {
                        Text("Logout")
                    }
                }
            }.navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        //SettingsView()
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            SettingsView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayAppPay.session)
    }
}
