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
    @State private var badgeNumber: Int = 3
    @State private var selection: MainView.Tab = .amount

    private var badgePosition: CGFloat = 1
    private var tabsCount: CGFloat = CGFloat(Tab.allCases.count)

    enum Tab: Hashable, CaseIterable {
        case cards
        case cart
        case products
        case amount
        case reports
        case settings
    }
    
    func merchantTabView() -> AnyView {
//        let displayMerchantOption = session.doesUserHasMerchantAccount
        let displayMerchantOption = true
        return AnyView(
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    // TabView
                    TabView(selection: $selection) {
                        if !displayMerchantOption {
                            CardsView()
                                .tabItem {
                                    Label("Card", systemImage: "creditcard")
                                        .accessibility(label: Text("Card"))
                            }
                            .tag(Tab.cards)
                        }
                        if displayMerchantOption {
                            ShoppingCartView()
                                .tabItem {
                                    Label("Cart", systemImage: "cart")
                                        .accessibility(label: Text("Cart"))
                            }
                            .tag(Tab.cart)
                            ProductGalleryView().environmentObject(self.session)
                                .tabItem {
                                    Label("Catalogue", systemImage: "list.bullet")
                                        .accessibility(label: Text("Catalogue"))
                            }
                            .tag(Tab.products)
                            AmountView().environmentObject(self.session)
                                .tabItem {
                                    Label("Amount", systemImage: "eurosign.circle")
                                        .accessibility(label: Text("Amount"))
                            }
                            .tag(Tab.amount)
                        }
                        
                        TransactionsView()
                            .tabItem {
                                Label("Reports", systemImage: "chart.bar")
                                    .accessibility(label: Text("Reports"))
                        }
                        .tag(Tab.reports)
                        SettingsView().environmentObject(self.session)
                            .tabItem {
                                Label("Settings", systemImage: "gear")
                                    .accessibility(label: Text("Settings"))
                        }
                        .tag(Tab.settings)
                    } // TabView
                    // Badge View
                    if displayMerchantOption {
                        ZStack {
                            Circle()
                                .foregroundColor(.red)
                            Text("\(self.session.shoppingCart.count)")
                                .foregroundColor(.white)
                                .font(Font.system(size: 12))
                        }
                        .frame(width: 20, height: 20)
                        .offset(x: ( ( 2 * self.badgePosition) - 1 ) * ( geometry.size.width / ( 2 * self.tabsCount ) ), y: -30)
                        .opacity(self.session.shoppingCart.count == 0 ? 0 : 1)
                    }
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
        MainView().environmentObject(WayAppPay.session)
    }
}
