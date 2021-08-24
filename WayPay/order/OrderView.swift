//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI


struct OrderView: View {
    @EnvironmentObject private var session: WayPay.Session
    
    var body: some View {
        List {
            ForEach(session.products) { product in
                OrderRowView(product: product)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Order")
        .navigationBarItems(trailing:
                                NavigationLink(destination: ShoppingCartView()) {
                                    Image(systemName: "cart")
                                        .imageScale(.large)
                                }
                                .overlay(Badge())
        )
    }
    
    func delete(at offsets: IndexSet) {
        WayPay.Product.delete(at: offsets)
    }

}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            OrderView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayPay.session)
    }
}
