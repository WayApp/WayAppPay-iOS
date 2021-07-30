//
//  CampaignsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var session: WayPay.Session

    var rewards: [WayPay.Reward]

    var body: some View {
        List {
            ForEach(rewards) { reward in
                HStack {
                    Image(systemName: session.campaigns[reward.campaignID]?.icon() ?? "xmark.octagon")
                    VStack(alignment: .leading) {
                        Text(session.campaigns[reward.campaignID]?.name ?? "")
                        Text(session.campaigns[reward.campaignID]?.description ?? "no description")
                            .font(.subheadline)
                        Spacer()
                        Text("Balance" + ": " + String(reward.balance ?? 0))
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }

}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView(rewards: [])
    }
}
