//
//  CampaignView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 23/6/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct PointNewView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var session: WayPay.Session
    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()

    @State private var prizeFormat: WayPay.Prize.Format = .CASHBACK
    @State private var prizeAmount: String = "0"
    @State private var prizeName: String = "1st prize"
    @State private var prize: WayPay.Prize = WayPay.Prize(campaignID: "", name: "", message: "", amountToGetIt: 0)
    @State var newName: String = ""
    @State var expires: Bool = false
    @State private var expirationDate = Date()
    @State private var amountToPrize: Double = 10.0
    @State var campaignCreateError: Bool = false
    @State private var threshold: String = "0"
    @State private var becomeFirstResponder = false
        
    let campaign: WayPay.Campaign?

    private var shouldSaveButtonBeDisabled: Bool {
        return (newName.isEmpty || threshold == "0")
    }

    var body: some View {
        Form {
            Section(header: Label("Name", systemImage: "checkmark.seal.fill")
                        .accessibility(label: Text("Name"))
                        .font(.caption)) {
                TextField(session.merchant?.name ?? "", text: $newName)
                    .textContentType(.name)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Section(header: Label("Configuration", systemImage: "gearshape")
                        .accessibility(label: Text("Configuration"))
                        .font(.caption)) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Amount to reach prize") + Text(":")
                        TextField("\(threshold)", text: $threshold)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    Toggle(NSLocalizedString("Expires?", comment: "PointNewView"), isOn: $expires)
                    if expires {
                        DatePicker(selection: $expirationDate, in: Date()..., displayedComponents: .date) {
                            Text("Campaign expires on")
                        }
                    }
                }
            }
            Section(header: Label("Prize", systemImage: "person.2.circle")
                        .accessibility(label: Text("Prize"))
                        .font(.caption)) {
                VStack(alignment: .leading) {
                    Text("Reward customers with") + Text(":")
                    Picker(NSLocalizedString("Prize format", comment: "WayPay.Prize.Format.") + " -> ", selection: $prize.format) {
                        ForEach(WayPay.Prize.Format.allCases, id: \.self) { format in
                            Text(format.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(Color.green)
                    HStack {
                        Text(prize.format.amountTitle) + Text(":")
                        TextField("\(prizeAmount)", text: $prizeAmount)
                            .frame(width: 80)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text(" " + prize.format.amountSymbol)
                        Spacer()
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
                                                      format: .POINT,
                                                      expirationDate: expirationDate, state: .ACTIVE)
                    prize.name = prizeName
                    prize.value = (Int(prizeAmount) ?? 0) * 100
                    prize.amountToGetIt = (Int(threshold) ?? 0) * 100
                    prize.message = WayPay.Prize.winnningMessage

                    let pointCampaign: WayPay.Point =
                        WayPay.Point(campaign: campaign,
                                           paymentAmountConvertibleToPrize: (Int(threshold) ?? 0) * 100,
                                           prizes: [prize])
                    WayPay.Point.create(pointCampaign) { campaigns, error in
                        if let campaigns = campaigns {
                            for campaign in campaigns {
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
                }) {
                    Text("Activate")
                        .padding()
                        .foregroundColor(Color.white)
                }
                .disabled(shouldSaveButtonBeDisabled)
                .buttonStyle(WayPay.WideButtonModifier())
                .alert(isPresented: $campaignCreateError) {
                    Alert(title: Text("Error creating the campaign"),
                          message: Text("Try again. If problem persists contact support@wayapp.com"),
                          dismissButton: .default(Text(WayPay.SingleMessage.OK.text)))
                }
                Spacer()
            }
        } // Form
        .onAppear(perform: {
            newName = session.merchant?.name ?? ""
        })
        .navigationBarTitle(NSLocalizedString("Setup", comment: "PointNewView"), displayMode: .inline)
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
    } // body
}

struct PointView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
    }
}
