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
                Section(header:
                            Label("Merchants", systemImage: "building.2.crop.circle")
                                .font(.callout)) {
                    if session.merchants.isEmpty {
                        Text("There are no merchants")
                    } else {
                        Picker(selection: $session.seletectedMerchant, label: Label("Merchant", systemImage: "building")) {
                            ForEach(0..<session.merchants.count) {
                                Text(self.session.merchants[$0].name ?? "Name")
                                    .font(Font.caption)
                                    .fontWeight(.light)
                            }
                        }
                        .onChange(of: session.seletectedMerchant, perform: { merchant in
                            session.saveSelectedMerchant()
                        })
                    }
                    NavigationLink(destination: ProductGalleryView()) {
                        Label("Product catalogue", systemImage: "list.bullet.rectangle")
                    }
                }
                Section(header: Label("Accounts", systemImage: "person.2.circle")
                                .font(.callout)) {
                    if WayAppPay.session.accounts.isEmpty {
                        Text("There are no accounts")
                    } else {
                        Picker(selection: $session.selectedAccount, label: Label("Account", systemImage: "person.fill.checkmark")) {
                            ForEach(0..<WayAppPay.session.accounts.count) {
                                Text(WayAppPay.session.accounts[$0].email ?? "no email")
                                    .font(.caption)
                                    .fontWeight(.light)
                            }
                        }
                    }
                    NavigationLink(destination: CardsView()) {
                        Label("Payment tokens", systemImage: "qrcode")
                    }
                    Button {
                        self.changePIN = true
                    } label: {
                        Label("Change PIN", systemImage: "lock.rotation.open")
                            .accessibility(label: Text("Change PIN"))
                    }
                    .sheet(isPresented: self.$changePIN) {
                        ChangePinView()
                    }
                    Button {
                        DispatchQueue.main.async {
                            self.session.logout()
                            WayAppPay.session.accounts.empty()
                            WayAppPay.session.account?.email = ""
                        }
                    } label: {
                        Label("Logout", systemImage: "chevron.left.square")
                            .accessibility(label: Text("Logout"))
                    }

                }
                .onAppear(perform:{
                    WayAppUtils.Log.message("+++++++++++ ACCOUNTS COUNT=\(WayAppPay.session.accounts.count)") })
                .accentColor(.primary)
                .listItemTint(Color("WAP-GreenDark"))

            }
            .navigationBarTitle("Settings", displayMode: .inline)
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
