//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    
    var body: some View {
        NavigationView {
            List {
                ForEach(session.products) { product in
                    OrderRowView(product: product)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Order")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        ShoppingCartView()
                    }, label: {
                        Label("Cart", systemImage: "cart")
                            .accessibility(label: Text("Cart"))
                    })
                }
                .foregroundColor(Color("MintGreen"))
                .frame(height: 30)
            )

        }
    }
    
    func delete(at offsets: IndexSet) {
        WayAppPay.Product.delete(at: offsets)
    }

}

struct OrderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            OrderView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayAppPay.session)
    }
}
