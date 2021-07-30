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
    @State var stampCampaign: WayPay.Stamp?
    @State var pointCampaign: WayPay.Point?
    @State var isStampCampaignActive: Bool = true
    @State var isPointCampaignActive: Bool = true
    @State var navigationSelection: Int?
    @State var inputAmount: Bool = false
    @State private var purchaseAmount: String = ""

    var body: some View {
        VStack {
            Form {
                Section(header:
                            Label(NSLocalizedString("Point", comment: "CampaignsView: section title"), systemImage: WayPay.Campaign.icon(format: .POINT))
                            .font(.callout)) {
                    if let pointCampaign = pointCampaign {
                        Text(pointCampaign.name)
                        HStack {
                            Toggle("", isOn: $isPointCampaignActive)
                                .onChange(of: isPointCampaignActive, perform: {value in
                                    pointCampaign.toggleState() { campaigns, error in
                                        if let campaigns = campaigns,
                                           let campaign = campaigns.first {
                                            DispatchQueue.main.async {
                                                isPointCampaignActive = campaign.state == .ACTIVE
                                            }
                                        }
                                    }
                                })
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color("MintGreen")))
                            Spacer()
                            if (!inputAmount) {
                                Button {
                                    inputAmount = true
                                } label: {
                                    Text("Award points")
                                        .padding()
                                }
                                .buttonStyle(WayPay.StampButtonModifier())
                                .disabled(!isPointCampaignActive)
                            }
                            Spacer()
                            Button {
                                WayPay.Campaign.delete(id: pointCampaign.id, sponsorUUID: pointCampaign.sponsorUUID, format: .POINT) { result, error in
                                    if error == nil {
                                        DispatchQueue.main.async {
                                            session.points.remove(pointCampaign)
                                            session.campaigns.remove(pointCampaign)
                                            self.pointCampaign = nil
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
                        if (inputAmount) {
                            VStack {
                                Text("Enter purchase amount:")
                                    .font(.title2)
                                TextField("\(purchaseAmount)", text: $purchaseAmount)
                                    .frame(width: 120)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                HStack {
                                    Button {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        purchaseAmount = ""
                                        self.navigationSelection = 1
                                        inputAmount = true
                                    } label: {
                                        Text("Award points")
                                            .padding()
                                    }
                                    .buttonStyle(WayPay.StampButtonModifier())
                                    .disabled(purchaseAmount.isEmpty)
                                    Spacer()
                                    Button {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        purchaseAmount = ""
                                        inputAmount = false
                                    } label: {
                                        Text("Cancel")
                                            .padding()
                                    }
                                    .buttonStyle(WayPay.StampButtonModifier())
                                }
                            } // VStack
                        }
                    } else {
                        NavigationLink(destination: PointNewView(campaign: nil)) {
                            Label(NSLocalizedString("Configure", comment: "CampaignAction button label") , systemImage: "plus.app")
                                .accessibility(label: Text("Configure"))
                        }
                    }
                } // Section POINT
                Section(header:
                            Label(NSLocalizedString("Stamp", comment: "CampaignsView: section title"), systemImage: WayPay.Campaign.icon(format: .STAMP))
                            .font(.callout)) {
                    if let stampCampaign = stampCampaign {
                        Text(stampCampaign.name)
                        HStack {
                            Toggle("", isOn: $isStampCampaignActive)
                                .onChange(of: isStampCampaignActive, perform: {value in
                                    stampCampaign.toggleState() { campaigns, error in
                                        if let campaigns = campaigns,
                                           let campaign = campaigns.first {
                                            DispatchQueue.main.async {
                                                isStampCampaignActive = campaign.state == .ACTIVE
                                            }
                                        }
                                    }
                                })
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color("MintGreen")))
                            Spacer()
                            Button {
                                self.navigationSelection = 0
                            } label: {
                                Text("Stamp")
                                    .padding()
                            }
                            .buttonStyle(WayPay.StampButtonModifier())
                            .disabled(!isStampCampaignActive)
                            Spacer()
                            Button {
                                WayPay.Campaign.delete(id: stampCampaign.id, sponsorUUID: stampCampaign.sponsorUUID, format: .STAMP) { result, error in
                                    if error == nil {
                                        DispatchQueue.main.async {
                                            session.stamps.remove(stampCampaign)
                                            session.campaigns.remove(stampCampaign)
                                            self.stampCampaign = nil
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
                    } else {
                        NavigationLink(destination: StampNewView(campaign: nil)) {
                            Label(NSLocalizedString("Configure", comment: "CampaignAction button label") , systemImage: "plus.app")
                                .accessibility(label: Text("Configure"))
                        }
                    }
                } // Section STAMP
            }
            .navigationBarTitle(Text("Campaigns"))
            .onAppear(perform: {
                stampCampaign = WayPay.Campaign.activeStampCampaign()
                pointCampaign = WayPay.Campaign.activePointCampaign()
                isStampCampaignActive = stampCampaign?.state == .ACTIVE
                isPointCampaignActive = pointCampaign?.state == .ACTIVE
                inputAmount = false
            })
            NavigationLink(destination: ScanView(campaign: stampCampaign, value: 0), tag: 0, selection: $navigationSelection) {
                EmptyView()
            }
            NavigationLink(destination: ScanView(campaign: pointCampaign, value: Int((Double(purchaseAmount) ?? 0)) * 100), tag: 1, selection: $navigationSelection) {
                EmptyView()
            }
        }
        
    }
    
    func delete(at offsets: IndexSet) {
        WayPay.Campaign.delete(at: offsets)
    }
    
}

struct CampaignsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
    }
}






/*
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
 */
