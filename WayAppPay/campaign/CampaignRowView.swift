//
//  CampaignRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 7/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI


struct PointRowView: View {
    @EnvironmentObject var session: WayAppPay.Session
    
    var body: some View {
        List {
            ForEach(session.points) { campaign in
                NavigationLink(destination: CampaignView(campaign: campaign)) {
                    VStack(alignment: .leading) {
                        Text(campaign.name)
                            .font(.headline)
                        Text(campaign.description ?? "no description")
                            .font(.caption)
                    }
                    .contextMenu {
                        Button {
                            campaign.toggleState { campaigns, error in
                                if let campaigns = campaigns,
                                   let updatedCampaign = campaigns.first {
                                    WayAppUtils.Log.message("Campaign: \(updatedCampaign.name), changed state to \(updatedCampaign.state!)")
                                    DispatchQueue.main.async {
                                        session.points[campaign.id]?.state = updatedCampaign.state
                                        campaign.state = updatedCampaign.state
                                    }
                                } else if let error = error  {
                                    WayAppUtils.Log.message("Campaign: \(campaign.name) could not toggle state. Error: \(error.localizedDescription)")
                                } else {
                                    WayAppUtils.Log.message("API ERROR")
                                }

                            }
                        } label: {
                            campaign.state == .ACTIVE ?
                                Label("Disable", systemImage: "envelope")
                                .accessibility(label: Text("Disable")) :
                                Label("Enable", systemImage: "envelope")
                                .accessibility(label: Text("Enable"))
                        }
                    }
                }
            }
            .onDelete(perform: delete)
        }
    }
    
    func delete(at offsets: IndexSet) {
        WayAppUtils.Log.message("Entering")
        if let offset = offsets.first {
            WayAppPay.Campaign.delete(id: session.points[offset].id, sponsorUUID: session.points[offset].sponsorUUID, format: session.points[offset].format) { strings, error in
                if let error = error {
                    WayAppUtils.Log.message("Campaign: \(session.points[offset].name) could not be . Error: \(error.localizedDescription)")
                } else {
                    WayAppUtils.Log.message("Campaign: \(session.points[offset].name) deleted successfully")
                    DispatchQueue.main.async {
                        session.points.remove(session.points[offset])
                    }

                }
            }
        }
    }

}

struct PointRowView_Previews: PreviewProvider {
    static var previews: some View {
        PointRowView()
    }
}

struct StampRowView: View {
    var campaign: WayAppPay.Stamp

    var body: some View {
        VStack(alignment: .leading) {
            Text(campaign.name)
                .font(.headline)
            Text(campaign.description ?? "no description")
                .font(.caption)
        }
        .contextMenu {
            Button {
                campaign.toggleState { campaigns, error in
                    if let campaigns = campaigns,
                       let updatedCampaign = campaigns.first {
                        WayAppUtils.Log.message("Campaign: \(updatedCampaign.name), changed state to \(updatedCampaign.state!)")
                        DispatchQueue.main.async {
                            //session.stamps[campaign.id]?.state = updatedCampaign.state
                            campaign.state = updatedCampaign.state
                        }
                    } else if let error = error  {
                        WayAppUtils.Log.message("Campaign: \(campaign.name) could not toggle state. Error: \(error.localizedDescription)")
                    } else {
                        WayAppUtils.Log.message("API ERROR")
                    }

                }
            } label: {
                campaign.state == .ACTIVE ?
                    Label("Disable", systemImage: "envelope")
                    .accessibility(label: Text("Disable")) :
                    Label("Enable", systemImage: "envelope")
                    .accessibility(label: Text("Enable"))
            }
        }
    }

}

struct StampRowView_Previews: PreviewProvider {
    static var previews: some View {
        StampRowView(campaign: WayAppPay.Stamp(name: "test", sponsorUUID: "", format: WayAppPay.Campaign.Format.STAMP, minimumPaymentAmountToGetStamp: 10))
    }
}
