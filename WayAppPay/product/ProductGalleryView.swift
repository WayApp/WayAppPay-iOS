//
//  ProductGalleryView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductGalleryView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @State var testToggle: Bool = true
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $testToggle) {
                    Text("Show Favorites Only")
                }
                
                ForEach(session.products) { product in
                    NavigationLink(
                        destination: ProductDetailView(product: product)
                    ) {
                        ProductRowView(product: product)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Products")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: { }, label: { Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) })
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 16)
                    Button(action: { }, label: { Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) })
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 16)
                }
                
            )
        }
    }
    
    func delete(at offsets: IndexSet) {
        session.products.remove(at: offsets)
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
