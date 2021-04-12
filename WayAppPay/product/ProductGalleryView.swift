//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductGalleryView: View {
    @ObservedObject var session = WayAppPay.session
    
    var body: some View {
        NavigationView {
            List {
                ForEach(session.products) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        ProductRowView(product: product)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Products", displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: ProductDetailView(product: nil)) {   Image(systemName: "plus.circle")
                        .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                }
                .aspectRatio(contentMode: .fit)
            )
        }
    }
    
    func delete(at offsets: IndexSet) {
        WayAppPay.Product.delete(at: offsets)
    }

}

struct ProductGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ProductGalleryView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayAppPay.session)
    }
}
