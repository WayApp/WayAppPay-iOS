//
//  CampaignView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CampaignView: View {
    let campaign: WayAppPay.Campaign?

    @EnvironmentObject private var session: WayAppPay.Session
    @State private var format: WayAppPay.Campaign.Format = .STAMP
    @State var newName: String = ""
    @State var newDescription: String = ""
    @State var minimumPurchaseAmountRequired: Bool = false
    @State var expires: Bool = false
    @State private var expirationDate = Date()
    @State private var amountToPrize: Double = 10.0
    @State var campaignCreateError: Bool = false
    @State private var prize: WayAppPay.Prize = WayAppPay.Prize(name: "", message: "")
    @State private var threshold: String = "0"
    @State private var prizeAmount: String = "0"
    @State private var prizeName: String = "1st prize"

    private var shouldSaveButtonBeDisabled: Bool {
        return (newName.isEmpty)
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $format, label: Text("Campaign format?")) {
                    Label(NSLocalizedString("Stamp", comment: "Stamp campaign format"), systemImage: "rectangle.and.pencil.and.ellipsis")
                        .tag(WayAppPay.Campaign.Format.STAMP)
                    Label(NSLocalizedString("Point", comment: "Point cam,paign format"), systemImage: "number")
                        .tag(WayAppPay.Campaign.Format.POINT)
                 }
                 .pickerStyle(SegmentedPickerStyle())
                Text("This is some longer text that is limited to three lines maximum, so anything more than that will cause the text to clip.")
                    .lineLimit(6)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color("MintGreen"), lineWidth: 0.5)
                        )
                Form {
                    Section(header: Label("Name", systemImage: "person.2.circle")
                                .accessibility(label: Text("Name"))
                                .font(.callout)) {
                        Text("Name")
                        TextField("\(campaign?.name ?? "name")", text: $newName)
                            .textContentType(.name)
                            .keyboardType(.default)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .stroke(Color("MintGreen"), lineWidth: 0.5)
                            )
                        Text("Description")
                        TextEditor(text: $newDescription)
                            .font(.body)
                            .keyboardType(.default)
                            .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color("MintGreen"), lineWidth: 0.5))
                    }
                    Section(header: Label("Configuration", systemImage: "person.2.circle")
                                .accessibility(label: Text("Configuration"))
                                .font(.callout)) {
                        VStack(alignment: .leading) {
                            switch (format) {
                            case .STAMP:
                                Text("How to get a stamp?")
                                Toggle("Set minimum purchase amount", isOn: $minimumPurchaseAmountRequired)
                                if minimumPurchaseAmountRequired {
                                    HStack {
                                        Text("Minimum purchase amount")
                                        TextField("\(threshold)", text: $threshold)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                                VStack(alignment: .leading) {
                                    Text("Number of stamps to get prize: \(Int(amountToPrize))")
                                    Slider(value: $amountToPrize, in: 1...25, step: 1)
                                }
                                Text("Prize description")
                                TextEditor(text: $prize.message)
                                    .font(.body)
                                    .keyboardType(.default)
                                    .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color("MintGreen"), lineWidth: 0.5))
                            case .POINT:
                                HStack {
                                    Text("Assign a point for every:")
                                    TextField("\(threshold)", text: $threshold)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            default:
                                Text("Error")
                            }
                            Toggle("Campain has an expiration date", isOn: $expires)
                            if expires {
                                DatePicker(selection: $expirationDate, in: Date()..., displayedComponents: .date) {
                                    Text("Campaign expires on")
                                }
                            }
                        }
                    }
                    Section(header: Label("Prize", systemImage: "person.2.circle")
                                .accessibility(label: Text("Prize"))
                                .font(.callout)) {
                        if ((threshold as NSString).doubleValue > 0) {
                            HStack {
                                TextField("0", text: $prizeAmount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("\(Int((prizeAmount as NSString).doubleValue / (threshold as NSString).doubleValue)) points")
                                TextField("\(prizeName)", text: $prizeName)
                                    .textContentType(.name)
                                    .keyboardType(.default)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .background(
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .stroke(Color("MintGreen"), lineWidth: 0.5))
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            if (!expires) {
                                expirationDate = Date.distantFuture
                            }
                            switch (format) {
                            case .STAMP:
                                prize.threshold = Int(amountToPrize)
                            case .POINT:
                                prize.threshold = Int((prizeAmount as NSString).doubleValue / (threshold as NSString).doubleValue)
                                prize.name = prizeName
                            }
                            switch(format) {
                            case .POINT:
                                let campaign: WayAppPay.Point =
                                    WayAppPay.Point(name: newName,
                                                       description: newDescription,
                                                       sponsorUUID: session.merchantUUID!,
                                                       format: format,
                                                       expirationDate: expirationDate, paymentAmountConvertibleToRewardUnit: 100)
                                WayAppPay.Point.create(campaign) { campaigns, error in
                                    if let campaigns = campaigns {
                                        for campaign in campaigns {
                                            WayAppUtils.Log.message("Campaign: \(campaign)")
                                            DispatchQueue.main.async {
                                                session.points.add(campaign)
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            campaignCreateError = true
                                        }
                                        WayAppUtils.Log.message("Campaign creation error. More info: \(error != nil ? error!.localizedDescription : "not available")")
                                    }
                                }
                            case .STAMP:
                                let campaign: WayAppPay.Stamp =
                                    WayAppPay.Stamp(name: newName,
                                                       description: newDescription,
                                                       sponsorUUID: session.merchantUUID!,
                                                       format: format,
                                                       expirationDate: expirationDate, minimumPaymentAmountToGetStamp: 10)

                                WayAppPay.Stamp.create(campaign) { campaigns, error in
                                    if let campaigns = campaigns,
                                       let campaign = campaigns.first {
                                        WayAppUtils.Log.message("Campaign: name: \(campaign.name), prize name: \(campaign.prize?.name ?? "no prize name")")
                                        DispatchQueue.main.async {
                                            session.stamps.add(campaign)
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            campaignCreateError = true
                                        }
                                        WayAppUtils.Log.message("Campaign creation error. More info: \(error != nil ? error!.localizedDescription : "not available")")
                                    }
                                }

                            }
                        }) {
                            Text("Activate campaign")
                                .padding()
                                .foregroundColor(Color.white)
                        }
                        .disabled(shouldSaveButtonBeDisabled)
                        .buttonStyle(WayAppPay.ButtonModifier())
                        .alert(isPresented: $campaignCreateError) {
                            Alert(title: Text("Error creating the campaign"),
                                  message: Text("Try again. If problem persists contact support@wayapp.com"),
                                  dismissButton: .default(Text("OK")))
                        }
                        Spacer()
                    }
                }
            }
        }
    } // body
}

struct CampaignView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignView(campaign: WayAppPay.Campaign(name: "Sample name", sponsorUUID: "sponsorUUID", format: .POINT))
    }
}
