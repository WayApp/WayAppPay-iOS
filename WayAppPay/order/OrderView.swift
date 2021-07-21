//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct Badge: View {
    @EnvironmentObject var session: WayAppPay.Session

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            Text(String(session.shoppingCart.count))
                .font(.system(size: 16))
                .padding(5)
                .background(Color.red)
                .foregroundColor(Color.white)
                .clipShape(Circle())
                // custom positioning in the top-right corner
                .alignmentGuide(.top) { $0[.bottom] }
                .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
                .opacity(session.shoppingCart.count == 0 ? 0 : 1)
        }
    }
}


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
                    .overlay(Badge())
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
