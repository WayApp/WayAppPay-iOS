//
//  ContentView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 11/24/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    
    enum Tab: Hashable {
        case cart
        case products
        case amount
        case reports
        case settings
    }
    
    var body: some View {
        if session.showAuthenticationView {
            return AnyView(AuthenticationView())
        } else {
            return AnyView(TabView(selection: $session.selectedTab) {
                ShoppingCartView()
                    .tabItem {
                        VStack {
                            Image(systemName: "cart")
                            Text("Cart")
                        }
                    }
                .tag(Tab.cart)
                ProductGalleryView().environmentObject(session)
                    .tabItem {
                        VStack {
                            Image(systemName: "tag")
                            Text("Products")
                        }
                    }
                .tag(Tab.products)
                AmountView()
                    .tabItem {
                        VStack {
                            Image(systemName: "eurosign.circle")
                            Text("Amount")
                        }
                    }
                .tag(Tab.amount)
                TransactionsView()
                    .tabItem {
                        VStack {
                            Image(systemName: "chart.bar")
                            Text("Reports")
                        }
                    }
                .tag(Tab.reports)
                SettingsView().environmentObject(session)
                    .tabItem {
                        VStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }
                .tag(Tab.settings)
            })
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(WayAppPay.session)
    }
}
