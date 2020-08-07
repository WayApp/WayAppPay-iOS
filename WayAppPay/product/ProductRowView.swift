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
    //var productIndex: Int

    var body: some View {
        HStack {
            ImageView(withURL: product.image)
            VStack(alignment: .leading, spacing: 1.0) {
                Text(product.name ?? WayAppPay.Product.defaultName)
                Text("\(WayAppPay.priceFormatter(product.price))")
            }
        }
        .onTapGesture {
            WayAppPay.session.shoppingCart.addProduct(self.product)
        }
        .contextMenu {
            NavigationLink(destination: ProductDetailView(product: self.product)) {
                Text("Detail Product")
            }
            Button("Delete Product") {
                self.product.delete()
            }
        
    }
}
}

struct ProductRowView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowView(product: WayAppPay.Product(name: "no name", price: 100))
    }
}
