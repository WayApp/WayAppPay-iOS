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
    @State var isStampCampaignActive: Bool = true
    @State var isPointCampaignActive: Bool = true
    @State var navigationSelection: Int?
    @State private var purchaseAmount: String = ""
    @State private var shouldStampCampaignToggleCallAPI = false
    @State private var shouldPointCampaignToggleCallAPI = false

    var body: some View {
        Form {
            Section(header:
                        Label(NSLocalizedString("Reward visits", comment: "CampaignsView: section title"), systemImage: WayPay.Campaign.icon(format: .STAMP))
                        .font(.callout)) {
                if let stampCampaign = session.activeStampCampaign() {
                    Text(stampCampaign.name)
                    HStack {
                        Toggle("", isOn: $isStampCampaignActive)
                            .onChange(of: isStampCampaignActive, perform: {value in
                                if shouldStampCampaignToggleCallAPI {
                                    stampCampaign.toggleState() { campaigns, error in
                                        if let campaigns = campaigns,
                                           let campaign = campaigns.first {
                                            session.campaigns[campaign.id]?.state = campaign.state
                                            session.stamps[campaign.id]?.state = campaign.state
                                        }
                                    }
                                }
                                shouldStampCampaignToggleCallAPI = true
                            })
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        Spacer()
                        Button {
                            WayPay.Campaign.delete(id: stampCampaign.id, sponsorUUID: stampCampaign.sponsorUUID, format: .STAMP) { result, error in
                                if error == nil {
                                    DispatchQueue.main.async {
                                        session.stamps.remove(stampCampaign)
                                        session.campaigns.remove(stampCampaign)
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .frame(width: 48.0, height: 48.0)
                                .foregroundColor(Color.red)
                        }
                    }
                    .onAppear(perform: {
                        isStampCampaignActive = session.activeStampCampaign()?.state == .ACTIVE
                    })
                } else {
                    Text("Reward customers by number of visits. The more they visit, the more cashbask or discounts they get.")
                        .font(.caption)
                    NavigationLink(destination: StampNewView(campaign: nil)) {
                        Label(NSLocalizedString("Get started, is free!", comment: "CampaignAction button label") , systemImage: "checkmark.seal.fill")
                            .accessibility(label: Text("Configure"))
                            .foregroundColor(Color("MintGreen"))
                    }
                }
            } // Section STAMP
            .listItemTint(Color.green)
            Section(header:
                        Label(NSLocalizedString("Reward consumption", comment: "CampaignsView: section title"), systemImage: WayPay.Campaign.icon(format: .POINT))
                        .font(.callout)) {
                if !session.points.isEmpty {
                    if let pointCampaign = session.activePointCampaign() {
                        Text(pointCampaign.name)
                        HStack {
                            Toggle("", isOn: $isPointCampaignActive)
                                .onChange(of: isPointCampaignActive, perform: {value in
                                    if shouldPointCampaignToggleCallAPI {
                                        pointCampaign.toggleState() { campaigns, error in
                                            if let campaigns = campaigns,
                                               let campaign = campaigns.first {
                                                session.campaigns[campaign.id]?.state = campaign.state
                                                session.points[campaign.id]?.state = campaign.state
                                            }
                                        }
                                    }
                                    self.shouldPointCampaignToggleCallAPI = true
                                })
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            Spacer()
                            Button {
                                WayPay.Campaign.delete(id: pointCampaign.id, sponsorUUID: pointCampaign.sponsorUUID, format: .POINT) { result, error in
                                    if error == nil {
                                        DispatchQueue.main.async {
                                            session.points.remove(pointCampaign)
                                            session.campaigns.remove(pointCampaign)
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .resizable()
                                    .frame(width: 48.0, height: 48.0)
                                    .foregroundColor(Color.red)
                            }
                        }
                        .onAppear(perform: {
                            isPointCampaignActive = session.activePointCampaign()?.state == .ACTIVE
                        })
                    }
                }  else {
                    Text("Reward customers by amount of accumulated purchases. The more they spend, the more cashbask or discounts they get.")
                        .font(.caption)
                    if let merchant = session.merchant {
                        if merchant.allowsPointCampaign {
                            NavigationLink(destination: PointNewView(campaign: nil)) {
                                Label(NSLocalizedString("Configure", comment: "CampaignAction button label") , systemImage: "checkmark.seal.fill")
                                    .accessibility(label: Text("Configure"))
                            }
                        } else {
                            Link(NSLocalizedString("Contact sales@wayapp.com to enable", comment: "Request points campaign feature"), destination: URL(string: "mailto:sales@wayapp.com?subject=Reward by € consumption&body=Hello, I am interested in using this feature. Please contact me. Thanks.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                                .font(.caption)
                                .foregroundColor(Color.blue)
                        }
                    }
                }
            } // Section POINT
            .listItemTint(Color.green)
            Section(header:
                        Label(NSLocalizedString("Rechargable giftcard", comment: "SettingsView: section title"), systemImage: "gift")
                        .font(.callout)) {
                Text("Sell your own digital giftcard. Customers pay you, you scan card, and top it up.")
                    .font(.caption)
                Link(NSLocalizedString("Contact sales@wayapp.com to enable", comment: "Request giftcard feature"), destination: URL(string: "mailto:sales@wayapp.com?subject=My own giftcard&body=Hello, I am interested in selling my own digital rechargable giftcard. Please contact me. Thanks.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
                    .font(.caption)
                    .foregroundColor(Color.blue)
            } // Section Giftcard
            .listItemTint(Color("MintGreen"))
            Section(header:
                        Label(NSLocalizedString("My business", comment: "SettingsView: section title"), systemImage: "cart")
                        .font(.callout)) {
                if session.merchants.isEmpty {
                    Text("No merchant registered")
                } else if session.merchants.count == 1,
                          let merchant = session.merchant {
                    Text(merchant.name ?? "-")
                        .bold()
                } else {
                    Picker(selection: $session.seletectedMerchant, label: Label("Merchant", systemImage: "building")
                            .accessibility(label: Text("Merchant"))) {
                        ForEach(0..<session.merchants.count) {
                            Text(self.session.merchants[$0].name ?? "no name")
                                .font(Font.caption)
                                .fontWeight(.light)
                        }
                    }
                    .onChange(of: session.seletectedMerchant, perform: { merchant in
                        session.saveSelectedMerchant()
                    })
                }
                NavigationLink(destination: CheckoutQRView()) {
                    Label(NSLocalizedString("Checkout QR", comment: "SettingsView: CheckoutQRView option"), systemImage: "qrcode")
                }
                NavigationLink(destination: ProductGalleryView()) {
                    Label(NSLocalizedString("Product catalogue", comment: "SettingsView: merchants products"), systemImage: "list.bullet.rectangle")
                }
                NavigationLink(destination: CustomerQRView()) {
                    Label(NSLocalizedString("Customer registration QR", comment: "SettingsView: CheckoutQRView option"), systemImage: "person.badge.plus")
                }
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
                            .accessibility(label: Text("Support"))
                            .font(.callout)) {
                    Button {
                        DispatchQueue.main.async {
                            self.updatePoint()
                        }
                    } label: {
                        Label("Update POINT", systemImage: "plus.viewfinder")
                            .accessibility(label: Text("Update POINT"))
                    }
                    Button {
                        DispatchQueue.main.async {
                            self.updateStamp()
                        }
                    } label: {
                        Label("Update STAMP", systemImage: "plus.viewfinder")
                            .accessibility(label: Text("Update STAMP"))
                    }
                    Button {
                        DispatchQueue.main.async {
                            self.getCampaigns()
                        }
                    } label: {
                        Label("Get campaigns", systemImage: "plus.viewfinder")
                            .accessibility(label: Text("Get campaigns"))
                    }
                    Button {
                        DispatchQueue.main.async {
                            self.getCampaign(id: "2275f746-ddaa-436e-9ceb-9b0a5ed3d6cb", sponsorUUID: "bd2b99d0-cf03-4d60-b1b8-ac050ed5614b", format: WayPay.Campaign.Format.POINT)
                        }
                    } label: {
                        Label("Get campaign detail", systemImage: "plus.viewfinder")
                            .accessibility(label: Text("Get campaigns"))
                    }
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
                .listItemTint(Color.red)
            }
        } // Form
        .accentColor(.primary)
        .edgesIgnoringSafeArea(.all)
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
    
    private func updatePoint() {
        let campaign = session.points.first;
        campaign?.name = "UpdatedNameForPoint"
        WayPay.Point.update(campaign!) { campaigns, error in
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
    
    private func updateStamp() {
        if let campaign = session.stamps.first {
            WayAppUtils.Log.message("Campaign: name BEFORE UPDATE: \(campaign.name), prize name: \(campaign.prize?.name ?? "no prize name")")
            campaign.name = "UPDATEDNameForStamp"
            WayPay.Stamp.update(campaign) { campaigns, error in
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
    }
    
    private func getCampaigns() {
        WayPay.Campaign.get(merchantUUID: "sponsorUUID004", issuerUUID: nil, campaignType: WayPay.Stamp.self, format: .STAMP) { campaigns, error in
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
        /*
        WayPay.Account.register(registration:
                                    WayPay.Registration(email: "coco@wayapp.com", issuerUUID: "f157c0c5-49b4-445a-ad06-70727030b38a"))
 */
    }
    
    private func deleteAccount() {
        WayPay.Account.delete("1e7e11a2-7d9a-4afa-bb66-66d874c9c136")
    }

}
