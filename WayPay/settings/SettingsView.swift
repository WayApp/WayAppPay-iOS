//
//  SettingsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

extension String: ContainerProtocol {
    public var id: String {
        return self
    }
}

struct SettingsView: View {
    @EnvironmentObject var session: WayPayApp.Session
    @State private var changePIN = false
    @State private var showBankAuthenticationView = false
    @State private var authURL: String? = nil
    @State private var purchaseAmount: String = ""
    @State private var shouldStampCampaignToggleCallAPI = false
    @State private var shouldPointCampaignToggleCallAPI = false
    @State var consumerRegistrationSelection: Int?
    
    var body: some View {
        Form {
            if let account = session.account,
               account.isWayPay {
                Section(header: Label("WayPay", systemImage: "ladybug")
                    .font(.callout)) {
                        NavigationLink(destination: AccountsView()) {
                            Label(NSLocalizedString("Accounts", comment: "WayPayAdminView: Accounts option"), systemImage: "person.fill")
                        }
                        NavigationLink(destination:  CustomersView()) {
                            Label(NSLocalizedString("Customers", comment: "WayPayAdminView: Customers option"), systemImage: "signature")
                        }
                    }
            }
            Section(header:
                        Label(NSLocalizedString("My business", comment: "SettingsView: section title"), systemImage: "cart")
                .font(.callout)) {
                    if let merchant = session.merchant {
                        Text(merchant.name ?? "-")
                            .bold()
                    } else {
                        Text("No merchant registered")
                    }
                    NavigationLink(destination: CheckoutQRView()) {
                        Label(NSLocalizedString("Print Checkout QR", comment: "SettingsView: CheckoutQRView option"), systemImage: "qrcode")
                    }
                    /*
                     NavigationLink(destination: ConsumerRegistrationView()) {
                     Label(NSLocalizedString("Register customer", comment: "SettingsView: CheckoutQRView option"), systemImage: "person.badge.plus")
                     }
                     NavigationLink(destination: CustomerQRView()) {
                     Label(NSLocalizedString("Print Registration QR", comment: "SettingsView: CheckoutQRView option"), systemImage: "printer.dotmatrix")
                     }
                     */
                }
                .listItemTint(Color.green)
            Section(header: Label(NSLocalizedString("My account", comment: "SettingsView: section title"), systemImage: "person")
                .accessibility(label: Text("My account"))
                .font(.callout)) {
                    if let email = session.email {
                        Text(email)
                            .bold()
                    }
                    NavigationLink(destination: OnboardingView(fromSettings: true)) {
                        Label(NSLocalizedString("Tutorial", comment: "SettingsView: OnboardingView option"), systemImage: "questionmark.video")
                    }
                    Button {
                        self.changePIN = true
                    } label: {
                        Label("Change PIN", systemImage: "lock.square")
                            .accessibility(label: Text("Change PIN"))
                    }
                    .sheet(isPresented: self.$changePIN) {
                        ChangePinView()
                    }
                    Button {
                        DispatchQueue.main.async {
                            self.session.logout()
                            WayPayApp.session.account?.email = ""
                        }
                    } label: {
                        Label("Logout", systemImage: "chevron.left.square")
                            .accessibility(label: Text("Logout"))
                    }
                }
                .listItemTint(Color.green)
            if let account = session.account,
               account.isCommunity {
                Section(header: Label("Community", systemImage: "person.3.sequence.fill")
                    .font(.callout)) {
                        Button {
                            DispatchQueue.main.async {
                                self.sendPushNotificationToMerchant()
                            }
                        } label: {
                            Label("Send merchant push", systemImage: "message.fill")
                        }
                        Group { // Campaign
                            Button {
                                DispatchQueue.main.async {
                                    self.sendPushNotificationToCampaign()
                                }
                            } label: {
                                Label("Send campaign push", systemImage: "message")
                            }
                        }
                    }
            }
        } // Form
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        //SettingsView()
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            SettingsView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayPayApp.session)
    }
}

extension SettingsView {
    
    private func sendPushNotificationToMerchant() {
        let pushNotification = WayPay.PushNotification(text: "Hello José, Welcome to WayPay's Push Notifications")
        Logger.message("Sending merchant pushNotification with text: \(pushNotification.text)")
        session.merchant?.sendPushNotification(pushNotification: pushNotification) { pushNotifications, error in
            if let pushNotifications = pushNotifications,
               let resultPush = pushNotifications.first {
                Logger.message("PushNotification text: \(resultPush.text)")
            } else if let error = error  {
                Logger.message("PushNotification ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("PushNotification ERROR is NIL")
            }
        }
        
    }
    
    private func sendPushNotificationToCampaign() {
        let pushNotification = WayPay.PushNotification(text: "Campaign announcement")
        Logger.message("Sending campaign pushNotification with text: \(pushNotification.text)")
        WayPay.Campaign.sendPushNotification(id: "bea4f43c-712b-4769-9b1a-8812062c28da", pushNotification: pushNotification) { pushNotifications, error in
            if let pushNotifications = pushNotifications,
               let resultPush = pushNotifications.first {
                Logger.message("PushNotification text: \(resultPush.text)")
            } else if let error = error  {
                Logger.message("PushNotification ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("PushNotification ERROR is NIL")
            }
        }
        
    }
}
