//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductGalleryView: View {
    @EnvironmentObject var session: WayPay.Session
    
    var body: some View {
        List {
            ForEach(session.products) { product in
                NavigationLink(destination: ProductDetailView(product: product)) {
                    ProductRowView(product: product)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text("Products"), displayMode: .inline)
        .navigationBarItems(trailing:
            NavigationLink(destination: ProductDetailView(product: nil)) {
                Text("New")
            }
        )
    }
    
    func delete(at offsets: IndexSet) {
        WayPay.Product.delete(at: offsets)
    }

}

struct ProductGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ProductGalleryView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayPay.session)
    }
}
