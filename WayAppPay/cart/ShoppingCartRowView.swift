//
//  ShoppingCartRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/6/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ShoppingCartRowView: View {
    
    struct Metrics {
        var thumbnailSize: CGFloat
        var cornerRadius: CGFloat
        var rowPadding: CGFloat
        var textPadding: CGFloat
    }

    var metrics: Metrics {
        #if os(iOS)
        return Metrics(thumbnailSize: 96, cornerRadius: 16, rowPadding: 0, textPadding: 8)
        #else
        return Metrics(thumbnailSize: 60, cornerRadius: 4, rowPadding: 2, textPadding: 0)
        #endif
    }

    var item: WayAppPay.ShoppingCartItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if item.isAmount {
                Image(systemName: "number.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WayAppPay.UI.shoppingCartRowImageSize, height: WayAppPay.UI.shoppingCartRowImageSize)
            } else {
                ImageView(withURL: item.product.image, size: WayAppPay.UI.shoppingCartRowImageSize)
                    .frame(width: metrics.thumbnailSize, height: metrics.thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous))
                    .accessibility(hidden: true)
           }
            Text("\(item.cartItem.quantity)").fontWeight(.bold)
            Text(verbatim: item.isAmount ?
                item.product.description == nil ? item.product.name ?? WayAppPay.Product.defaultName : item.product.description!
                :
                item.product.name ?? WayAppPay.Product.defaultName)
            Spacer()
            Text("\(WayAppPay.formatPrice(item.cartItem.price))").fontWeight(.bold)
        }
        .contextMenu {
            Button {
                self.addOne(self.item)
            } label: {
                Label("Add one", systemImage: "cart.badge.plus")
                    .accessibility(label: Text("Add one"))
            }
            Button {
                self.removeOne(self.item)
            } label: {
                Label("Remove one", systemImage: "cart.badge.minus")
                    .accessibility(label: Text("Remove one"))
            }
            Button {
                self.removeAll(self.item)
            } label: {
                Label("Remove all", systemImage: "cart")
                    .accessibility(label: Text("Remove all"))
            }
        }
    }
    
    private func removeOne(_ item: WayAppPay.ShoppingCartItem) {
        WayAppPay.session.shoppingCart.removeProduct(item.product)
    }
    
    private func addOne(_ item: WayAppPay.ShoppingCartItem) {
        WayAppPay.session.shoppingCart.addProduct(item.product)
    }
    
    private func removeAll(_ item: WayAppPay.ShoppingCartItem) {
        WayAppPay.session.shoppingCart.removeAllProduct(item.product)
    }
}

struct ShoppingCartRowView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartRowView(item: WayAppPay.ShoppingCartItem(product: WayAppPay.Product(merchantUUID: "", name: "no name", price: "100")))
    }
}
