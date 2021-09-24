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
    @State private var selection: MainView.Tab = Tab.checkout

    enum Tab: Hashable, CaseIterable {
        case checkout
        case checkin
        case reports
        case settings
        
        var title: String {
            switch self {
            case .checkout: return NSLocalizedString("Checkout", comment: "MainView tab title")
            case .checkin: return NSLocalizedString("Customer", comment: "MainView tab title")
            case .reports: return NSLocalizedString("Sales", comment: "MainView tab title")
            case .settings: return NSLocalizedString("Settings", comment: "MainView tab title")
            }
        }
        
        var icon: String {
            switch self {
            case .checkout: return "qrcode.viewfinder"
            case .checkin: return "person.fill"
            case .reports: return "chart.bar.xaxis"
            case .settings: return "gearshape.fill"
            }
        }

    }
    
    var body: some View {
        if !session.skipOnboarding {
            return AnyView(OnboardingView())
        } else if session.showAuthenticationView {
            return AnyView(
                NavigationView {
                    AuthenticationView()
                })
        } else {
            return merchantTabView()
        }
    }
    
    func merchantTabView() -> AnyView {
        return AnyView(
            TabView(selection: $selection) {
                NavigationView {
                    CheckoutView()
                }
                .tabItem {
                    Label(Tab.checkout.title, systemImage: Tab.checkout.icon)
                        .accessibility(label: Text(Tab.checkout.title))
                }
                .tag(Tab.checkout)
                NavigationView {
                    CheckinView().environmentObject(self.session)
                }
                
                .tabItem {
                    Label(Tab.checkin.title, systemImage: Tab.checkin.icon)
                        .accessibility(label: Text(Tab.checkin.title))
                }
                .tag(Tab.checkin)
                NavigationView {
                    TransactionsView()
                }
                .tabItem {
                    Label(Tab.reports.title, systemImage: Tab.reports.icon)
                        .accessibility(label: Text(Tab.reports.title))
                }
                .tag(Tab.reports)
                NavigationView {
                    SettingsView().environmentObject(self.session)
                }
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                        .accessibility(label: Text(Tab.settings.title))
                }
                .tag(Tab.settings)
            } // TabView
            .onAppear(perform: {
                WayAppUtils.Log.message("****** onAppear")
                session.storeManager.validateAutoReneawableSubscriptions()
            })
        ) // AnyView
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(WayPay.session)
    }
}
