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
                            Label(NSLocalizedString("Merchants", comment: "SettingsView: section title"), systemImage: "building.2.crop.circle")
                                .font(.callout)) {
                    if session.merchants.isEmpty {
                        Text("There are no merchants")
                    } else {
                        Picker(selection: $session.seletectedMerchant, label: Label("Merchant", systemImage: "building")
                                .accessibility(label: Text("Merchant"))) {
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
                        Label(NSLocalizedString("Product catalogue", comment: "SettingsView: merchants products"), systemImage: "list.bullet.rectangle")
                    }
                }
                Section(header: Label("Accounts", systemImage: "person.2.circle")
                            .accessibility(label: Text("Accounts"))
                            .font(.callout)) {
                    if WayAppPay.session.accounts.isEmpty {
                        Text("There are no accounts")
                    } else {
                        Picker(selection: $session.selectedAccount, label: Label("Account", systemImage: "person.fill.checkmark")
                                .accessibility(label: Text("Account"))) {
                            ForEach(0..<WayAppPay.session.accounts.count) {
                                Text(WayAppPay.session.accounts[$0].email ?? "no email")
                                    .font(.caption)
                                    .fontWeight(.light)
                            }
                        }
                    }
                    /*
                    NavigationLink(destination: CardsView()) {
                        Label("Payment tokens", systemImage: "qrcode")
                    }
 */
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
                .accentColor(.primary)
                .listItemTint(Color("WAP-GreenDark"))
                if (OperationalEnvironment.isSettingsSupportFunctionsActive) {
                    Section(header: Label("Support", systemImage: "ladybug")
                                .accessibility(label: Text("Support"))
                                .font(.callout)) {
                        Button {
                            DispatchQueue.main.async {
                                self.reward()
                            }
                        } label: {
                            Label("Reward", systemImage: "plus.viewfinder")
                                .accessibility(label: Text("Reward"))
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.redeem()
                            }
                        } label: {
                            Label("Redeem", systemImage: "minus.square")
                                .accessibility(label: Text("Redeem"))
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.expire()
                            }
                        } label: {
                            Label("Expire", systemImage: "calendar.badge.exclamationmark")
                                .accessibility(label: Text("Expire"))
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.registerAccount()
                            }
                        } label: {
                            Label("Register account", systemImage: "arrow.up.and.person.rectangle.portrait")
                                .accessibility(label: Text("Register account"))
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.deleteAccount()
                            }
                        } label: {
                            Label("Delete account", systemImage: "trash")
                                .accessibility(label: Text("Delete account"))
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.newSEPAs()
                            }
                        } label: {
                            Label("Generate SEPA file", systemImage: "banknote")
                                .accessibility(label: Text("Generate SEPA file"))
                        }

                    }
                    .accentColor(.primary)
                    .listItemTint(Color(.systemRed))
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
    
    private func reward() {
        // PAN Marzo31Superpapelería: 2CCFDE3A-10BC-40C5-AEAC-A7E74557F9BF
        let activeToken = "fGeIaln34rMMWO7xcwMGjZs-pi505orJgcKlbXm2e30=.fx7ZiW5S682i2iVUCGtHW7kMb3w+v8sICkq1x+Ykbylcn76-qNC84f3lJuZFzPIk+xm8-RgKFV-gEklxE1Q+NajNRHGvQwROtGe-KT0KeHQ=.13cd55e3c0e836c06a734f8705382d3d5a76b9bfec498934eb92971f9b96f66c"
        let C10 =  "c040399e-ab0b-4b25-ae55-cc12f9bb3c18"
        let C1 = "e5154471-ca71-448a-82d2-7b28712b88aa"
        let transaction = WayAppPay.PaymentTransaction(amount: 1000, token: activeToken)
        let campaignIDs = [C1, C10]
        WayAppPay.Campaign.reward(transaction: transaction, campaignIDs: campaignIDs) { campaigns, error in
            if let campaigns = campaigns {
                WayAppUtils.Log.message("Campaigns: \(campaigns)")
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Reward ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Reward ERROR: -------------")
            }
        }
    }
    
    private func redeem() {
        // PAN Marzo31Superpapelería: 2CCFDE3A-10BC-40C5-AEAC-A7E74557F9BF
        let activeToken = "fGeIaln34rMMWO7xcwMGjZs-pi505orJgcKlbXm2e30=.fx7ZiW5S682i2iVUCGtHW7kMb3w+v8sICkq1x+Ykbylcn76-qNC84f3lJuZFzPIk+xm8-RgKFV-gEklxE1Q+NajNRHGvQwROtGe-KT0KeHQ=.13cd55e3c0e836c06a734f8705382d3d5a76b9bfec498934eb92971f9b96f66c"
        let C10 =  "c040399e-ab0b-4b25-ae55-cc12f9bb3c18"
        let C1 = "e5154471-ca71-448a-82d2-7b28712b88aa"
        let transaction = WayAppPay.PaymentTransaction(amount: 100, token: activeToken)
        let campaignIDs = [C1]
        WayAppPay.Campaign.redeem(transaction: transaction, campaignIDs: campaignIDs) { campaigns, error in
            if let campaigns = campaigns {
                WayAppUtils.Log.message("Campaigns: \(campaigns)")
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Redeem ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Redeem ERROR: -------------")
            }
        }
    }
    
    private func expire() {
//        let issuerUUIDLasRozas = "f157c0c5-49b4-445a-ad06-70727030b38a"
        let issuerUUIDAsCancelas = "65345945-0e04-47b2-ae08-c5e7022a71aa"
//        let issuerUUIDParquesur = "12412d65-411b-4629-a9ce-b5fb281b11bd"
        WayAppPay.Issuer.expireCards(issuerUUID: issuerUUIDAsCancelas) { issuers, error in
            WayAppUtils.Log.message("Issuers name: \(issuers?.debugDescription)")
            if let issuers = issuers {
                WayAppUtils.Log.message("Issuer name: ")
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Expire ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Expire ERROR: -------------")
            }
        }
    }
    
    private func getCampaign(id: String, sponsorUUID: String) {
        WayAppPay.Campaign.get(campaignID: id, sponsorUUID: sponsorUUID) { campaigns, error in
            if let campaigns = campaigns {
                for campaign in campaigns {
                    WayAppUtils.Log.message("Campaign: \(campaign)")
                }
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
            }
        }
    }
    
    private func getCampaign() {
        WayAppPay.Campaign.get(merchantUUID: "", issuerUUID: "100") { campaigns, error in
            if let campaigns = campaigns {
                WayAppUtils.Log.message("Campaigns count: \(campaigns.count)")
                for campaign in campaigns {
                    WayAppUtils.Log.message("Campaign: \(campaign)")
                }
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
            }
        }
    }
    
    private func createCampaign() {
        let campaign: WayAppPay.Campaign = WayAppPay.Campaign(name: "C10", sponsorUUID: "100", format: .POINT)
        WayAppPay.Campaign.create(campaign) { campaigns, error in
            if let campaigns = campaigns {
                for campaign in campaigns {
                    WayAppUtils.Log.message("Campaign: \(campaign)")
                }
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
            }
        }

    }
    
    private func newSEPAs() {
        WayAppPay.Merchant.newSEPAS(initialDate: "2021-04-15", finalDate: "2021-04-21") { transactions, error in
            if let transactions = transactions {
                WayAppUtils.Log.message("Transactions count: \(transactions.count)")
                for transaction in transactions {
                    WayAppUtils.Log.message("Transaction: \(transaction)")
                }
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: -------------")
            }
        }
    }

    private func getIssuerTransactions() {
        // Las Rozas issuerUUID: f157c0c5-49b4-445a-ad06-70727030b38a
        // Parquesur issuerUUID staging: 6fae922e-9a08-48a8-859d-d9e8a0d54f21
        // As Cancelas issuerUUID staging: dd5ed363-88ce-4308-9cf2-20f3930d7cfd

        WayAppPay.Issuer.getTransactions(issuerUUID: "1338193f-c6d9-4c19-a7d8-1c80fe9f017f", initialDate: "2021-04-15", finalDate: "2021-04-19") { transactions, error in
            if let transactions = transactions {
                WayAppUtils.Log.message("Transactions count: \(transactions.count)")
                for transaction in transactions {
                    WayAppUtils.Log.message("Transaction: \(transaction)")
                }
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Transaction ERROR: -------------")
            }
        }
    }
    
    private func registerAccount() {
        WayAppPay.Account.registerAccount(registration:
                                            WayAppPay.Registration(email: "m3@wayapp.com", issuerUUID: "dd5ed363-88ce-4308-9cf2-20f3930d7cfd"))
    }
    
    private func deleteAccount() {
        WayAppPay.Account.delete("1e7e11a2-7d9a-4afa-bb66-66d874c9c136")
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
