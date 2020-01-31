//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductDetailView: View {
    let product: WayAppPay.Product
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayAppPay.Product())
    }
}
