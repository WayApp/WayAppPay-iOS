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
    private var badgePosition: CGFloat = 1
    private var tabsCount: CGFloat = CGFloat(Tab.allCases.count)

    enum Tab: Hashable, CaseIterable {
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
            return AnyView(
                GeometryReader { geometry in
                  ZStack(alignment: .bottomLeading) {
                    // TabView
                    TabView(selection: self.$session.selectedTab) {
                        ShoppingCartView()
                            .tabItem {
                                VStack {
                                    Image(systemName: "cart")
                                    Text("Cart")
                                }
                            }
                        .tag(Tab.cart)
                        ProductGalleryView().environmentObject(self.session)
                            .tabItem {
                                VStack {
                                    Image(systemName: "tag")
                                    Text("Products")
                                }
                            }
                        .tag(Tab.products)
                        AmountView().environmentObject(self.session)
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
                        SettingsView().environmentObject(self.session)
                            .tabItem {
                                VStack {
                                    Image(systemName: "gear")
                                    Text("Settings")
                                }
                            }
                        .tag(Tab.settings)
                    }
                    // Badge View
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
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(WayAppPay.session)
    }
}
