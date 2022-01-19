//
//  IssuerAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct IssuerAdminView: View {
    @EnvironmentObject var session: WayPayApp.Session

    var body: some View {
        Form {
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
            Button {
                DispatchQueue.main.async {
                    self.getIssuerTransactions()
                }
            } label: {
                Label("Get transactions", systemImage: "plus.viewfinder")
            }
            Button {
                DispatchQueue.main.async {
                    self.newSEPAs()
                }
            } label: {
                Label("Generate SEPA file", systemImage: "banknote")
            }
        }
        .navigationBarTitle(Text("Issuer"), displayMode: .inline)
        .foregroundColor(.primary)
    }
}

struct IssuerAdminView_Previews: PreviewProvider {
    static var previews: some View {
        IssuerAdminView()
    }
}

extension IssuerAdminView {
    private func newSEPAs() {
        WayPay.Merchant.newSEPAS(initialDate: "2021-04-15", finalDate: "2021-04-21") { transactions, error in
            if let transactions = transactions {
                Logger.message("Transactions count: \(transactions.count)")
                for transaction in transactions {
                    Logger.message("Transaction: \(transaction)")
                }
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Transaction ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Transaction ERROR: -------------")
            }
        }
    }
        
    
    private func getIssuerTransactions() {
        // Las Rozas issuerUUID: f157c0c5-49b4-445a-ad06-70727030b38a
        // Parquesur issuerUUID staging: 6fae922e-9a08-48a8-859d-d9e8a0d54f21
        // As Cancelas issuerUUID staging: dd5ed363-88ce-4308-9cf2-20f3930d7cfd
        
        WayPay.Issuer.getTransactions(issuerUUID: "1338193f-c6d9-4c19-a7d8-1c80fe9f017f", initialDate: "2021-04-15", finalDate: "2021-04-19") { transactions, error in
            if let transactions = transactions {
                Logger.message("Transactions count: \(transactions.count)")
                for transaction in transactions {
                    Logger.message("Transaction: \(transaction)")
                }
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Transaction ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Transaction ERROR: -------------")
            }
        }
    }

    private func reward() {
        // PAN Marzo31Superpapelería: 2CCFDE3A-10BC-40C5-AEAC-A7E74557F9BF
        let activeToken = "fGeIaln34rMMWO7xcwMGjZs-pi505orJgcKlbXm2e30=.fx7ZiW5S682i2iVUCGtHW7kMb3w+v8sICkq1x+Ykbylcn76-qNC84f3lJuZFzPIk+xm8-RgKFV-gEklxE1Q+NajNRHGvQwROtGe-KT0KeHQ=.13cd55e3c0e836c06a734f8705382d3d5a76b9bfec498934eb92971f9b96f66c"
        let C10 =  "c040399e-ab0b-4b25-ae55-cc12f9bb3c18"
        let C1 = "e5154471-ca71-448a-82d2-7b28712b88aa"
        let transaction = WayPay.PaymentTransaction(amount: 1000, token: activeToken)
        let campaignIDs = [C1, C10]
        WayPay.Campaign.reward(transaction: transaction, campaignIDs: campaignIDs) { campaigns, error in
            if let campaigns = campaigns {
                Logger.message("Campaigns: \(campaigns)")
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Reward ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Reward ERROR: -------------")
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
                Logger.message("Campaigns: \(campaigns)")
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Redeem ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Redeem ERROR: -------------")
            }
        }
    }

    private func getCampaign(id: String, sponsorUUID: String, format: WayPay.Campaign.Format) {
        WayPay.Campaign.get(campaignID: id, sponsorUUID: sponsorUUID, format: format) { campaigns, error in
            if let campaigns = campaigns {
                for campaign in campaigns {
                    Logger.message("Campaign: \(campaign)")
                }
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
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
                    Logger.message("Campaign: \(campaign.name)")
                }
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
            }
        }

    }
    
    private func getCampaigns() {
        WayPay.Campaign.get(merchantUUID: nil, issuerUUID: "f157c0c5-49b4-445a-ad06-70727030b38a") { campaigns, error in
            if let campaigns = campaigns {
                Logger.message("Campaigns count: \(campaigns.count)")
                for campaign in campaigns {
                    Logger.message("Campaign: \(campaign)")
                }
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Campaign ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Campaign ERROR: -------------")
            }
        }
    }
    
    private func deleteCampaign() {
        WayPay.Campaign.delete(id: "LasRozasPoint0001", sponsorUUID: "f157c0c5-49b4-445a-ad06-70727030b38a")
    }

}
