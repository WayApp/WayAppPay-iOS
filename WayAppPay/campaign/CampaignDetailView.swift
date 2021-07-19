//
//  CampaignDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 14/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CampaignDetailView: View {
    
    enum DisplayOption {
        case transactions, customers
    }
    var campaign: WayAppPay.Campaign
    @State private var displayOption: DisplayOption = .transactions

    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(NSLocalizedString("Expires on", comment: "CampaignDetailView: campaign expires on") + ": ", systemImage: "calendar")
                .font(.callout)
                Text(campaign.expirationDate != nil ?
                        ("\(WayAppPay.displayDateFormatter.string(from: campaign.expirationDate!))") :
                        NSLocalizedString("none", comment: "CampaignDetailView: campaign expires on"))
                Spacer()
                Button {
                    // Edit campaign
                } label: {
                    Label(NSLocalizedString("Edit campaign", comment: "CampaignDetailView: edit campaign"), systemImage: "square.and.pencil")
                        .accessibility(label: Text("Edit campaign"))
                }
                Spacer()
                Image(systemName: campaign.state.icon)
                    .foregroundColor(campaign.state.color)
            }
            .padding()
            Text("Active customers")
                .padding(.horizontal)
            Text("Stamps granted")
                .padding(.horizontal)
            Text("Prizes redeemed")
                .padding(.horizontal)
            Text("Pending prizes")
                .padding(.horizontal)
        }
        .navigationBarTitle(campaign.name, displayMode: .inline)
        Picker(selection: $displayOption, label: Text("Display option?")) {
            Label(NSLocalizedString("Transactions", comment: "CampaignDetailView: campaign transactions"), systemImage: "rectangle.and.pencil.and.ellipsis")
                .tag(DisplayOption.transactions)
            Label(NSLocalizedString("Customers", comment: "CampaignDetailView: campaign customers"), systemImage: "number")
                .tag(DisplayOption.customers)
         }
        .padding()
        .labelsHidden()
        .pickerStyle(SegmentedPickerStyle())
        switch (displayOption) {
        case .transactions:
            Text("Transactions list")
        case .customers:
            Text("Customers list")
        }
        Spacer()
    }
}

struct CampaignDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignDetailView(campaign: WayAppPay.Campaign())
    }
}
