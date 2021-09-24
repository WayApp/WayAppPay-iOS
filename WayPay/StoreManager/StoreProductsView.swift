//
//  StoreProducts.swift
//  WayPay
//
//  Created by Oscar Anzola on 17/9/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct StoreProductsView: View {
    @EnvironmentObject private var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List(session.storeManager.myProducts, id: \.skProduct) { product in
            HStack {
                VStack(alignment: .leading) {
                    Text(product.0.localizedTitle)
                        .font(.headline)
                    Text(product.0.localizedDescription)
                        .font(.caption2)
                }
                Spacer()
                if UserDefaults.standard.bool(forKey: product.0.productIdentifier) {
                    Text ("Purchased")
                        .foregroundColor(.green)
                } else {
                    Button(action: {
                        session.storeManager.purchaseProduct(product: product.0)
                    }) {
                        Text("Buy for \(product.0.price)")
                    }
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationBarItems(trailing:
                                Button(action: {
                                    session.storeManager.restoreProducts()
                                }) {
                                    Text ("Restore Purchases ")
                                }
        )
    }
}

struct StoreProductsView_Previews: PreviewProvider {
    static var previews: some View {
        StoreProductsView()
    }
}
