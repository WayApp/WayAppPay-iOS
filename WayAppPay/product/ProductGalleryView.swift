//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

let products: [WayAppPay.Product] = [WayAppPay.Product(), WayAppPay.Product(), WayAppPay.Product()]

struct ProductGalleryView: View {
    @State var testToggle: Bool = true
    var body: some View {
        List {
            Toggle(isOn: $testToggle) {
                Text("Show Favorites Only")
            }
            
            ForEach(products) { product in
                NavigationLink(
                    destination: ProductDetailView(product: product)
                ) {
                    ProductRowView(product: product)
                }
            }
        }
    }
}

struct ProductGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ProductGalleryView()
    }
}
