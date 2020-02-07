//
//  ProductRow.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductRowView: View {
    var product: WayAppPay.Product

    var body: some View {
        HStack {
            ImageView(withURL: product.image)
            VStack(alignment: .leading, spacing: 1.0) {
                Text(product.name ?? WayAppPay.Product.defaultName)
                Text("\(WayAppPay.priceFormatter(product.price))")
            }
        }
        .contextMenu {
            Button("Add to cart ➕") {
                WayAppPay.session.shoppingCart.addProduct(self.product)
            }
        }
    }
}

struct ProductRowView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowView(product: WayAppPay.Product(merchantUUID: "myMerchantUUID", name: "debug"))
    }
}
