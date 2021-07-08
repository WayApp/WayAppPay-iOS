//
//  CampaignsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CampaignsView: View {
    @EnvironmentObject var session: WayAppPay.Session

    var body: some View {
        NavigationView {
            List {
                ForEach(session.stamps) { campaign in
                    NavigationLink(destination: CampaignView(campaign: campaign)) {
                        StampRowView(campaign: campaign)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Campaigns"), displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: CampaignView(campaign: nil)) {
                    Image(systemName: "plus")
                        .resizable()
            })
        }
    }
    
    func delete(at offsets: IndexSet) {
        WayAppPay.Stamp.delete(at: offsets)
    }

}

struct CampaignsView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignsView()
            .environmentObject(WayAppPay.session)
    }
}
