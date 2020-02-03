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
            Text(verbatim: product.name ?? WayAppPay.Product.defaultName)
            Spacer()
        }
    }
}

struct ProductRowView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowView(product: WayAppPay.Product(merchantUUID: "myMerchantUUID", name: "debug"))
    }
}
