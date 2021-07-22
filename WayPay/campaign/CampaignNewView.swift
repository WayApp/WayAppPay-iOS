//
//  CampaignView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CampaignNewView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var session: WayPay.Session
    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()

    @State private var format: WayPay.Campaign.Format = .STAMP    
    @State private var prizeFormat: WayPay.Prize.Format = .MANUAL
    @State private var prizeAmount: String = "0"
    @State private var prizeName: String = "1st prize"
    @State private var prize: WayPay.Prize = WayPay.Prize(campaignID: "campaignID", name: "name", message: "message")
    @State var newName: String = ""
    @State var newDescription: String = ""
    @State var minimumPurchaseAmountRequired: Bool = false
    @State var expires: Bool = false
    @State var isActive: Bool = true
    @State private var expirationDate = Date()
    @State private var amountToPrize: Double = 10.0
    @State var campaignCreateError: Bool = false
    @State private var threshold: String = "0"

    let campaign: WayPay.Campaign?

    private var shouldSaveButtonBeDisabled: Bool {
        return (newName.isEmpty || threshold == "0")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Label("Type", systemImage: "person.2.circle")
                            .accessibility(label: Text("Type"))
                            .font(.callout)) {
                    Picker(selection: $format, label: Text("Campaign format?")) {
                        Label(NSLocalizedString("Stamp", comment: "Stamp campaign format"), systemImage: "rectangle.and.pencil.and.ellipsis")
                            .tag(WayPay.Campaign.Format.STAMP)
                        Label(NSLocalizedString("Point", comment: "Point cam,paign format"), systemImage: "number")
                            .tag(WayPay.Campaign.Format.POINT)
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
                }
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
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            VStack(alignment: .leading) {
                                Text("Number of stamps to get prize: \(Int(amountToPrize))")
                                Slider(value: $amountToPrize, in: 1...25, step: 1)
                            }
                        case .POINT:
                            HStack {
                                Text("Assign one point for every:")
                                TextField("\(threshold)", text: $threshold)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        Toggle("Has expiration date", isOn: $expires)
                        if expires {
                            DatePicker(selection: $expirationDate, in: Date()..., displayedComponents: .date) {
                                Text("Campaign expires on")
                            }
                        }
                        Toggle("Starts active", isOn: $isActive)
                    }
                }
                Section(header: Label("Prize", systemImage: "person.2.circle")
                            .accessibility(label: Text("Prize"))
                            .font(.callout)) {
                    Text("Prize winning message:")
                    TextEditor(text: $prize.message)
                        .font(.body)
                        .keyboardType(.default)
                        .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color("MintGreen"), lineWidth: 0.5))
                    switch (format) {
                    case .STAMP:
                        VStack(alignment: .leading) {
                            HStack {
                                Picker(selection: $prize.format, label: Text("Prize format" + " -> ")) {
                                    ForEach(WayPay.Prize.Format.allCases, id: \.self) { format in
                                        Text(format.title)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                Text(prize.format.title)
                            }
                            HStack {
                                Text("Prize amount")
                                TextField("\(prizeAmount)", text: $prizeAmount)
                                    .frame(width: 80)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Spacer()
                            }
                        }
                    case .POINT:
                        if ((threshold as NSString).doubleValue > 0) {
                            HStack {
                                TextField("0", text: $prizeAmount)
                                    .keyboardType(.numberPad)
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
                }
                HStack {
                    Spacer()
                    Button(action: {
                        if (!expires) {
                            expirationDate = Date.distantFuture
                        }
                        let campaign = WayPay.Campaign(name: newName,
                                                          description: newDescription,
                                                          sponsorUUID: session.merchantUUID!,
                                                          format: format,
                                                          expirationDate: expirationDate, state: isActive ? .ACTIVE : .INACTIVE)
                        prize.name = prizeName
                        prize.value = Int(prizeAmount)
                        switch(format) {
                        case .POINT:
                            prize.amountToGetIt = Int((prizeAmount as NSString).doubleValue / (threshold as NSString).doubleValue)
                            let campaign: WayPay.Point =
                                WayPay.Point(campaign: campaign,
                                                   paymentAmountConvertibleToRewardUnit: 100,
                                                   prizes: [prize])
                            WayPay.Point.create(campaign) { campaigns, error in
                                if let campaigns = campaigns {
                                    for campaign in campaigns {
                                        WayAppUtils.Log.message("Campaign: \(campaign)")
                                        DispatchQueue.main.async {
                                            session.points.add(campaign)
                                            session.campaigns.addAsFirst(campaign)
                                            self.presentationMode.wrappedValue.dismiss()
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
                            prize.amountToGetIt = Int(amountToPrize)
                            let campaign: WayPay.Stamp =
                                WayPay.Stamp(campaign: campaign,
                                                minimumPaymentAmountToGetStamp: minimumPurchaseAmountRequired
                                                ? Int(threshold) ?? Int.max:
                                                    Int.max,
                                                prize: prize)
                            WayPay.Stamp.create(campaign) { campaigns, error in
                                if let campaigns = campaigns,
                                   let campaign = campaigns.first {
                                    WayAppUtils.Log.message("Campaign: name: \(campaign.name), prize name: \(campaign.prize?.name ?? "no prize name")")
                                    DispatchQueue.main.async {
                                        session.stamps.add(campaign)
                                        session.campaigns.addAsFirst(campaign)
                                        self.presentationMode.wrappedValue.dismiss()
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
                    .buttonStyle(WayPay.ButtonModifier())
                    .alert(isPresented: $campaignCreateError) {
                        Alert(title: Text("Error creating the campaign"),
                              message: Text("Try again. If problem persists contact support@wayapp.com"),
                              dismissButton: .default(Text("OK")))
                    }
                    Spacer()
                }
            }
            .navigationBarTitle(Text("New campaign"), displayMode: .inline)
        } // NavigationView
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
    } // body
}

struct CampaignView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignNewView(campaign: WayPay.Campaign(name: "Sample name", sponsorUUID: "sponsorUUID", format: .POINT))
    }
}
