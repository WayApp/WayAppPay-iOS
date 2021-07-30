//
//  CampaignsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CampaignsView: View {
    @EnvironmentObject var session: WayPay.Session

    var body: some View {
        List {
            ForEach(session.campaigns) { campaign in
                NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                    CampaignRowView(campaign: campaign)
                }
            }
            .onDelete(perform: delete)
        }
        .edgesIgnoringSafeArea(.all)
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("Campaigns"))
        .navigationBarItems(trailing:
            NavigationLink(destination: CampaignNewView(campaign: nil)) {
                Image(systemName: "plus")
                    .resizable()
        })
    }
    
    func delete(at offsets: IndexSet) {
        WayPay.Campaign.delete(at: offsets)
    }

}

struct CampaignsView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignsView()
            .environmentObject(WayPay.session)
    }
}
