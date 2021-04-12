//
//  ProductRow.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductRowView: View {
    
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

    var product: WayAppPay.Product
    //var productIndex: Int

    var body: some View {
        HStack {
            HStack(alignment: .center) {
                ImageView(withURL: product.image)
                    .frame(width: metrics.thumbnailSize, height: metrics.thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous))
                    .accessibility(hidden: true)
                VStack(alignment: .leading, spacing: 1.0) {
                    Text(product.name ?? WayAppPay.Product.defaultName)
                    Text("\(WayAppPay.formatPrice(product.price))")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, metrics.textPadding)
                Spacer(minLength: 0)
            }
            .font(.headline)
            .padding(.vertical, metrics.rowPadding)
            .accessibilityElement(children: .combine)
        }
    }
}

struct ProductRowView_Previews: PreviewProvider {
    static var previews: some View {
        ProductRowView(product: WayAppPay.Product(merchantUUID: "", name: "no name", price: "100"))
    }
}
