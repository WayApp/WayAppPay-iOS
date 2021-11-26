//
//  SettingsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

extension String: ContainerProtocol {
    public var id: String {
        return self
    }
}

struct SettingsView: View {
    @EnvironmentObject var session: WayPay.Session
    @State private var changePIN = false
    @State private var showBankAuthenticationView = false
    @State private var authURL: String? = nil
    @State private var purchaseAmount: String = ""
    @State private var shouldStampCampaignToggleCallAPI = false
    @State private var shouldPointCampaignToggleCallAPI = false
    @State var consumerRegistrationSelection: Int?

    var body: some View {
        Form {
            Section(header:
                        Label(NSLocalizedString("My business", comment: "SettingsView: section title"), systemImage: "cart")
                        .font(.callout)) {
                if let merchant = session.merchant {
                    Text(merchant.name ?? "-")
                        .bold()
                } else {
                    Text("No merchant registered")
                }
                NavigationLink(destination: CheckoutQRView()) {
                    Label(NSLocalizedString("Print Checkout QR", comment: "SettingsView: CheckoutQRView option"), systemImage: "qrcode")
                }
                /*
                NavigationLink(destination: ConsumerRegistrationView()) {
                    Label(NSLocalizedString("Register customer", comment: "SettingsView: CheckoutQRView option"), systemImage: "person.badge.plus")
                }
                NavigationLink(destination: CustomerQRView()) {
                    Label(NSLocalizedString("Print Registration QR", comment: "SettingsView: CheckoutQRView option"), systemImage: "printer.dotmatrix")
                }
                 */
            }
            .listItemTint(Color.green)
            Section(header: Label(NSLocalizedString("My account", comment: "SettingsView: section title"), systemImage: "person")
                        .accessibility(label: Text("My account"))
                        .font(.callout)) {
                if let email = session.email {
                    Text(email)
                        .bold()
                }
                NavigationLink(destination: OnboardingView(fromSettings: true)) {
                    Label(NSLocalizedString("Tutorial", comment: "SettingsView: OnboardingView option"), systemImage: "questionmark.video")
                }
                Button {
                    self.changePIN = true
                } label: {
                    Label("Change PIN", systemImage: "lock.square")
                        .accessibility(label: Text("Change PIN"))
                }
                .sheet(isPresented: self.$changePIN) {
                    ChangePinView()
                }
                Button {
                    DispatchQueue.main.async {
                        self.session.logout()
                        WayPay.session.account?.email = ""
                    }
                } label: {
                    Label("Logout", systemImage: "chevron.left.square")
                        .accessibility(label: Text("Logout"))
                }
            }
            .listItemTint(Color.green)
            if (OperationalEnvironment.isSettingsSupportFunctionsActive) {
                Section(header: Label("Support", systemImage: "ladybug")
                            .font(.callout)) {
                    Group {
                        Button {
                            DispatchQueue.main.async {
                                self.sendPushNotificationToMerchant()
                            }
                        } label: {
                            Label("Send merchant push", systemImage: "message.fill")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.sendPushNotificationToCampaign()
                            }
                        } label: {
                            Label("Send campaign push", systemImage: "message")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.updateCampaign()
                            }
                        } label: {
                            Label("Update CAMPAIGN", systemImage: "plus.viewfinder")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.getCampaigns()
                            }
                        } label: {
                            Label("Get campaigns", systemImage: "plus.viewfinder")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.getCampaign(id: "2275f746-ddaa-436e-9ceb-9b0a5ed3d6cb", sponsorUUID: "bd2b99d0-cf03-4d60-b1b8-ac050ed5614b", format: WayPay.Campaign.Format.POINT)
                            }
                        } label: {
                            Label("Get campaign detail", systemImage: "plus.viewfinder")
                        }
                    }
                    Group {
                        Button {
                            DispatchQueue.main.async {
                                self.reward()
                            }
                        } label: {
                            Label("Reward", systemImage: "plus.viewfinder")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.redeem()
                            }
                        } label: {
                            Label("Redeem", systemImage: "minus.square")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.expire()
                            }
                        } label: {
                            Label("Expire", systemImage: "calendar.badge.exclamationmark")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.registerAccount()
                            }
                        } label: {
                            Label("Register account", systemImage: "arrow.up.and.person.rectangle.portrait")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.getCheckin()
                            }
                        } label: {
                            Label("Alcázar checkin", systemImage: "arrow.up.and.person.rectangle.portrait")
                        }
                    }
                    Group {
                        Button {
                            DispatchQueue.main.async {
                                self.deleteAccount()
                            }
                        } label: {
                            Label("Delete account", systemImage: "trash")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.deleteMerchant()
                            }
                        } label: {
                            Label("Delete merchant", systemImage: "trash")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.deleteCampaign()
                            }
                        } label: {
                            Label("Delete campaign", systemImage: "trash")
                        }
                        Button {
                            DispatchQueue.main.async {
                                self.newSEPAs()
                            }
                        } label: {
                            Label("Generate SEPA file", systemImage: "banknote")
                        }
                    }
                }
                .listItemTint(Color.red)
            }
        } // Form
        .navigationBarTitle("Settings")
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
        .environmentObject(WayPay.session)
    }
}

extension SettingsView {

    private func reward() {
        // PAN Marzo31Superpapelería: 2CCFDE3A-10BC-40C5-AEAC-A7E74557F9BF
        let activeToken = "fGeIaln34rMMWO7xcwMGjZs-pi505orJgcKlbXm2e30=.fx7ZiW5S682i2iVUCGtHW7kMb3w+v8sICkq1x+Ykbylcn76-qNC84f3lJuZFzPIk+xm8-RgKFV-gEklxE1Q+NajNRHGvQwROtGe-KT0KeHQ=.13cd55e3c0e836c06a734f8705382d3d5a76b9bfec498934eb92971f9b96f66c"
        let C10 =  "c040399e-ab0b-4b25-ae55-cc12f9bb3c18"
        let C1 = "e5154471-ca71-448a-82d2-7b28712b88aa"
        let transaction = WayPay.PaymentTransaction(amount: 1000, token: activeToken)
        let campaignIDs = [C1, C10]
        WayPay.Campaign.reward(transaction: transaction, campaignIDs: campaignIDs) { campaigns, error in
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
//        let C10 =  "c040399e-ab0b-4b25-ae55-cc12f9bb3c18"
        let C1 = "e5154471-ca71-448a-82d2-7b28712b88aa"
        let transaction = WayPay.PaymentTransaction(amount: 100, token: activeToken)
        let campaignIDs = [C1]
        WayPay.Campaign.redeem(transaction: transaction, campaignIDs: campaignIDs) { campaigns, error in
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
        let issuerUUIDLasRozas = "f157c0c5-49b4-445a-ad06-70727030b38a"
        //        let issuerUUIDAsCancelas = "65345945-0e04-47b2-ae08-c5e7022a71aa"
        //        let issuerUUIDParquesur = "12412d65-411b-4629-a9ce-b5fb281b11bd"
        WayPay.Issuer.expireCards(issuerUUID: issuerUUIDLasRozas) { issuers, error in
            if let _ = issuers {
                WayAppUtils.Log.message("Issuer name: ")
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Expire ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Expire ERROR: -------------")
            }
        }
    }
    
    private func getCampaign(id: String, sponsorUUID: String, format: WayPay.Campaign.Format) {
        WayPay.Campaign.get(campaignID: id, sponsorUUID: sponsorUUID, format: format) { campaigns, error in
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
    
    private func updateCampaign() {
        guard let campaign = session.campaigns.first else {
            return
        }
        campaign.name = "UpdatedNameForCAMPAIGN"
        WayPay.Campaign.update(campaign) { campaigns, error in
            if let campaigns = campaigns {
                for campaign in campaigns {
                    WayAppUtils.Log.message("Campaign: \(campaign.name)")
                }
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
            }
        }

    }
    
    private func getCampaigns() {
        WayPay.Campaign.get(merchantUUID: nil, issuerUUID: "f157c0c5-49b4-445a-ad06-70727030b38a") { campaigns, error in
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
        
    private func newSEPAs() {
        WayPay.Merchant.newSEPAS(initialDate: "2021-04-15", finalDate: "2021-04-21") { transactions, error in
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
        
        WayPay.Issuer.getTransactions(issuerUUID: "1338193f-c6d9-4c19-a7d8-1c80fe9f017f", initialDate: "2021-04-15", finalDate: "2021-04-19") { transactions, error in
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
        WayPay.Account.register(registration:
                                    WayPay.Registration(email: "coco@wayapp.com", issuerUUID: "7373d487-239e-4966-8988-8d2c81b83251")) { registrations, error in
            if let registrations = registrations,
               let registration = registrations.first {
                WayAppUtils.Log.message("Registration: \(registration)")
            } else if let error = error  {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Registration ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("%%%%%%%%%%%%%% Registration ERROR: -------------")
            }
        }

    }
    
    private func deleteAccount() {
        WayPay.Account.delete("40e53480-fd9d-495f-abf8-4ff6bebae6aa")
    }

    private func deleteMerchant() {
        WayPay.Merchant.delete("a3b4226a-f4b1-4638-8964-067b32c850bb")
        WayPay.Merchant.delete("f68108e9-347c-4cc9-97db-c7c86eb311cd")
    }

    private func deleteCampaign() {
        WayPay.Campaign.delete(id: "LasRozasPoint0001", sponsorUUID: "f157c0c5-49b4-445a-ad06-70727030b38a")
    }

    private func sendPushNotificationToMerchant() {
        let pushNotification = WayPay.PushNotification(text: "Hello José, Welcome to WayPay's Push Notifications")
        WayAppUtils.Log.message("Sending merchant pushNotification with text: \(pushNotification.text)")
        session.merchant?.sendPushNotification(pushNotification: pushNotification) { pushNotifications, error in
            if let pushNotifications = pushNotifications,
               let resultPush = pushNotifications.first {
                WayAppUtils.Log.message("PushNotification text: \(resultPush.text)")
            } else if let error = error  {
                WayAppUtils.Log.message("PushNotification ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("PushNotification ERROR is NIL")
            }
        }

    }

    private func sendPushNotificationToCampaign() {
        let pushNotification = WayPay.PushNotification(text: "Campaign announcement")
        WayAppUtils.Log.message("Sending campaign pushNotification with text: \(pushNotification.text)")
        WayPay.Campaign.sendPushNotification(id: "bea4f43c-712b-4769-9b1a-8812062c28da", pushNotification: pushNotification) { pushNotifications, error in
            if let pushNotifications = pushNotifications,
               let resultPush = pushNotifications.first {
                WayAppUtils.Log.message("PushNotification text: \(resultPush.text)")
            } else if let error = error  {
                WayAppUtils.Log.message("PushNotification ERROR: \(error.localizedDescription)")
            } else {
                WayAppUtils.Log.message("PushNotification ERROR is NIL")
            }
        }

    }

    private func getCheckin() {
        WayPay.Account.getCheckin(acccountUUID: "d7531225-a57f-4767-b0c8-70303b69cef9", issuerUUID: "7373d487-239e-4966-8988-8d2c81b83251") { checkins, error in
            if let checkins = checkins,
               let checkin = checkins.first {
                WayAppUtils.Log.message("Checkin: \(checkin)")
            } else {
                WayAppUtils.Log.message("Checkin error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
        
    }

}
