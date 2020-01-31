//
//  ContentView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 11/24/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @State private var selection = 1
 
    var body: some View {
        NavigationView {
            TabView(selection: $selection){
                ShoppingCartView()
                    .tabItem {
                        VStack {
                            Image(systemName: "cart")
                            Text("Cart")
                        }
                    }
                    .tag(0)
                ProductGalleryView()
                    .tabItem {
                        VStack {
                            Image(systemName: "tag")
                            Text("Products")
                        }
                    }
                    .tag(1)
                AmountView()
                    .tabItem {
                        VStack {
                            Image(systemName: "eurosign.circle")
                            Text("Amount")
                        }
                    }
                    .tag(2)
                ReportsView()
                    .tabItem {
                        VStack {
                            Image(systemName: "chart.bar")
                            Text("Reports")
                        }
                    }
                    .tag(3)
                SettingsView()
                    .tabItem {
                        VStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }
                    .tag(4)

            }
        //.navigationBarTitle("WayApp Pay")
        .navigationBarItems(trailing:
              CartButtonView()
            )

        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
