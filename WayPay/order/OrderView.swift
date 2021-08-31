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
    @State private var isProductCalogueEmpty = false

    var body: some View {
        List {
            ForEach(session.products) { product in
                OrderRowView(product: product)
            }
        }
        .onAppear(perform: {
            isProductCalogueEmpty = session.products.isEmpty
        })
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Order")
        .navigationBarItems(trailing:
                                NavigationLink(destination: ShoppingCartView()) {
                                    Image(systemName: "cart")
                                        .imageScale(.large)
                                }
                                .overlay(Badge())
                                .disabled(session.shoppingCart.isEmpty)
        )
        .alert(isPresented: $isProductCalogueEmpty) {
            Alert(
                title: Text(WayPay.AlertMessage.addProducts.text.title)
                    .font(.title),
                message: Text(WayPay.AlertMessage.addProducts.text.message),
                dismissButton: .default(
                    Text(WayPay.SingleMessage.OK.text),
                    action: {})
            )
        }
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
