//
//  ContentView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 11/24/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: WayPay.Session
    @State private var selection: MainView.Tab = .settings
    
    private var badgePosition: CGFloat = 1
    private var tabsCount: CGFloat = CGFloat(Tab.allCases.count)
    
    enum Tab: Hashable, CaseIterable {
        case cards
        case cart
        case order
        case checkin
        case POS
        case reports
        case settings
    }
    
    func merchantTabView() -> AnyView {
        return AnyView(
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    // TabView
                    TabView(selection: $selection) {
                        if !session.doesAccountHasMerchants {
                            CardsView()
                                .tabItem {
                                    Label("Card", systemImage: "creditcard.fill")
                                        .accessibility(label: Text("Card"))
                                }
                                .tag(Tab.cards)
                        }
                        if session.doesAccountHasMerchants {
                            NavigationView {
                                CampaignsView()
                            }
                            .tabItem {
                                Label("Campaign", systemImage: "megaphone.fill")
                                    .accessibility(label: Text("Campaign"))
                            }
                            .tag(Tab.cart)
                            NavigationView {
                                CheckinView().environmentObject(self.session)
                            }
                            
                            .tabItem {
                                Label("Checkin", systemImage: "qrcode.viewfinder")
                                    .accessibility(label: Text("Checkin"))
                            }
                            .tag(Tab.checkin)
                        }
                        NavigationView {
                            TransactionsView()
                        }
                        .tabItem {
                            Label("Sales", systemImage: "chart.bar.xaxis")
                                .accessibility(label: Text("Sales"))
                        }
                        .tag(Tab.reports)
                        NavigationView {
                            SettingsView().environmentObject(self.session)
                        }
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.2.fill")
                                .accessibility(label: Text("Settings"))
                        }
                        .tag(Tab.settings)
                    } // TabView
                }
            }
        ) // AnyView
    }
    
    var body: some View {
        if session.showAuthenticationView {
            return AnyView(AuthenticationView())
        } else {
            return merchantTabView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(WayPay.session)
    }
}
