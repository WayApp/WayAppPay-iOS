//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    var product: WayAppPay.Product
    
    @State var updatedProduct = WayAppPay.Product(merchantUUID: "dd", name: "")
    @State var newName: String = ""
    @State var newPrice: String = ""
    
    @State private var showImagePicker : Bool = false
    @State private var image : Image? = nil

    let imageSize: CGFloat = 120.0
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            if image == nil {
                ImageView(withURL: product.image, size: imageSize)
            } else {
                image!
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
            }
            Button(action: {
                self.showImagePicker = true
            }, label: {
                Image(systemName: "camera")
            })
            HStack(alignment: .center, spacing: 12) {
                Text("Name").fontWeight(.medium)
                TextField("\(product.name ?? WayAppPay.Product.defaultName)", text: $newName)
                    .background(Color("tertiarySystemBackgroundColor"))
                    .foregroundColor(.primary)
                    .cornerRadius(8)

            }
            HStack(alignment: .center, spacing: 12) {
                Text("Price").fontWeight(.medium)
                TextField("\(WayAppPay.priceFormatter(product.price))", text: $newPrice)
                .background(Color("tertiarySystemBackgroundColor"))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
        }
        .padding()
        .sheet(isPresented: self.$showImagePicker){
            PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$image)
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayAppPay.Product(merchantUUID: "uuid", name: "debug"))
    }
}
