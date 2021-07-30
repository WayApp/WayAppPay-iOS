//
//  CampaignView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct StampNewView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var session: WayPay.Session
    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()
    
    @State private var prizeFormat: WayPay.Prize.Format = .MANUAL
    @State private var prizeAmount: String = "0"
    @State private var prizeName: String = "1st prize"
    @State private var prize: WayPay.Prize = WayPay.Prize(campaignID: "", name: "", message: "", amountToGetIt: 0)
    @State var newName: String = ""
    @State var minimumPurchaseAmountRequired: Bool = false
    @State var expires: Bool = false
    @State private var expirationDate = Date()
    @State private var amountToPrize: Double = 10.0
    @State var campaignCreateError: Bool = false
    @State private var threshold: String = "0"
    
    let campaign: WayPay.Campaign?
    
    private var shouldSaveButtonBeDisabled: Bool {
        return (newName.isEmpty)
    }
    
    var body: some View {
        Form {
            Section(header: Label("Name", systemImage: "person.2.circle")
                        .accessibility(label: Text("Name"))
                        .font(.caption)) {
                TextField("", text: $newName)
                    .textContentType(.name)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color("MintGreen"), lineWidth: 0.5)
                    )
            }
            Section(header: Label("Configuration", systemImage: "person.2.circle")
                        .accessibility(label: Text("Configuration"))
                        .font(.caption)) {
                Toggle("Minimum purchase required?", isOn: $minimumPurchaseAmountRequired)
                if minimumPurchaseAmountRequired {
                    HStack {
                        Text("Amount")
                        TextField("\(threshold)", text: $threshold)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                Toggle("Expires?", isOn: $expires)
                if expires {
                    DatePicker(selection: $expirationDate, in: Date()..., displayedComponents: .date) {
                        Text("Expires on")
                    }
                }
            }
            Section(header: Label("Prize", systemImage: "person.2.circle")
                        .accessibility(label: Text("Prize"))
                        .font(.caption)) {
                VStack(alignment: .leading) {
                    Text("Stamps to get prize:") + Text(" \(Int(amountToPrize))").bold()
                    Slider(value: $amountToPrize, in: 1...25, step: 1)
                }
                Text("Winning message:")
                TextEditor(text: $prize.message)
                    .font(.body)
                    .keyboardType(.default)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color("MintGreen"), lineWidth: 0.5))
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
                    if (prize.format != .MANUAL) {
                        HStack {
                            Text("Amount")
                            TextField("\(prizeAmount)", text: $prizeAmount)
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Spacer()
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
                                                   description: "",
                                                   sponsorUUID: session.merchantUUID!,
                                                   format: .STAMP,
                                                   expirationDate: expirationDate, state: .ACTIVE)
                    prize.name = prizeName
                    prize.value = Int(prizeAmount)
                    prize.amountToGetIt = Int(amountToPrize)
                    let stampCampaign: WayPay.Stamp =
                        WayPay.Stamp(campaign: campaign,
                                     minimumPaymentAmountToGetStamp: minimumPurchaseAmountRequired ? Int(threshold) ?? 0: 0,
                                     prize: prize)
                    WayPay.Stamp.create(stampCampaign) { campaigns, error in
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
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
    } // body
}

struct StampView_Previews: PreviewProvider {
    static var previews: some View {
        StampNewView(campaign: WayPay.Campaign(name: "Sample name", sponsorUUID: "sponsorUUID", format: .POINT))
    }
}
