//
//  CheckinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 19/7/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CheckinView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var showQRScanner = true
    @State private var scannedCode: String? = nil
    @State private var isAPICallOngoing = false
    @State private var showAlert = false
    @State private var wasScanSuccessful: Bool = false
    @State private var checkin: WayAppPay.Checkin?
    @State private var selectedReward: Int = 0
    
    var fullname: String {
        if let checkin = checkin {
            return (checkin.firstName ?? "") + (checkin.lastName != nil ? " " + checkin.lastName! : "")
        }
        return ""
    }

    var body: some View {
        NavigationView {
            if (showQRScanner) {
                VStack {
                    CodeCaptureView(showCodePicker: self.$showQRScanner, code: self.$scannedCode, codeTypes: WayAppPay.acceptedPaymentCodes, completion: self.handleScan)
                    HStack {
                        Text("Checkin")
                            .foregroundColor(Color.black)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Done") { self.showQRScanner = false }
                    }
                    .frame(height: 40.0)
                    .padding()
                    .background(Color.white)
                }
            } else if isAPICallOngoing {
                ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
            } else if let checkin = checkin {
                Form {
                    if let rewards = checkin.rewards,
                       !rewards.isEmpty {
                        Section(header:
                                    Label(NSLocalizedString("Rewards", comment: "SettingsView: section title"), systemImage: "building.2.crop.circle")
                                    .font(.callout)) {
                            Text("Checkin: \(checkin.lastName ?? "no last name")")
                            Picker(selection: $selectedReward, label: Label("Reward", systemImage: "building")
                                    .accessibility(label: Text("Reward"))) {
                                ForEach(0..<rewards.count) {
                                    Text(rewards[$0].campaignID ?? "no campaignID")
                                        .font(Font.caption)
                                        .fontWeight(.light)
                                }
                            }
                            .onChange(of: selectedReward, perform: { merchant in
                                WayAppUtils.Log.message("selectedReward success")

                            })
                        }
                    }
                    Section(header:
                                Label(NSLocalizedString("Section 2", comment: "SettingsView: section title"), systemImage: "building.2.crop.circle")
                                .font(.callout)) {
                        Text("Checkin: \(checkin.firstName ?? "no first name")")
                    }
                }
                .navigationBarTitle(fullname, displayMode: .inline)
            } else {
                Text("Checkin is nil")
            }
            
                /*
                ZStack {
                    Form {
                        Section(header:
                                    Label(NSLocalizedString("Rewards", comment: "CheckinView: section title"), systemImage: "building.2.crop.circle")
                                    .font(.callout)) {
                            if let rewards = checkin.rewards,
                               !rewards.isEmpty {
                                Picker(selection: $selectedReward, label: Label("Reward", systemImage: "building")
                                        .accessibility(label: Text("Reward"))) {
                                    ForEach(0..<rewards.count) {
                                        Text(rewards[$0].campaignID ?? "no name")
                                            .font(Font.caption)
                                            .fontWeight(.light)
                                    }
                                }
                                .onChange(of: selectedReward, perform: { reward in
                                    WayAppUtils.Log.message("Selected reward success: \(reward)")
                                })
                            } else {
                                Text("There are no rewards")
                            }
                            NavigationLink(destination: ProductGalleryView()) {
                                Label(NSLocalizedString("Product catalogue", comment: "SettingsView: merchants products"), systemImage: "list.bullet.rectangle")
                            }
                        }
                    }
                    if isAPICallOngoing {
                        ProgressView(NSLocalizedString("Please wait…", comment: "Activity indicator"))
                    }
                } // ZStack
                 */
        } // NavigationView
    }
    
    private func handleScan() {
        WayAppUtils.Log.message("Checking in")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing scannedCode")
            return
        }
        let transaction = WayAppPay.PaymentTransaction(amount: 0, token: code, type: .CHECKIN)
        isAPICallOngoing = true
        WayAppPay.Account.checkin(transaction) { checkins, error in
            //self.scannedCode = nil
            if let checkins = checkins,
               let checkin = checkins.first {
                DispatchQueue.main.async {
                    self.checkin = checkin
                    isAPICallOngoing = false
                }
                WayAppUtils.Log.message("Checkin success: \(checkin)")
            } else {
                DispatchQueue.main.async {
                    // campaignCreateError = true
                }
                WayAppUtils.Log.message("Get rewards error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
    }
}

struct CheckinView_Previews: PreviewProvider {
    static var previews: some View {
        CheckinView()
    }
}
