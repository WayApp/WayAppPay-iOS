//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI
import UIKit

struct ProductDetailView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false

    var product: WayAppPay.Product?
    
    @State var newName: String = ""
    @State var newPrice: String = ""
    
    @State private var showImagePicker: Bool = false
    @State private var newImage: UIImage? = nil
    
    var shouldSaveButtonBeDisabled: Bool {
        if product == nil {
            // creation
            return newName.isEmpty || newPrice.isEmpty || newImage == nil
        } else {
            // update
            return newName.isEmpty && newPrice.isEmpty && newImage == nil
        }
    }
        
    private func apiCallCompleted(_ error: Error?) {
        DispatchQueue.main.async {
            self.isAPICallOngoing = false
            if error != nil {
                self.showUpdateResultAlert = true
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: WayAppPay.UI.verticalSeparation) {
            if newImage == nil {
                ImageView(withURL: product?.image)
            } else {
                Image(uiImage:newImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Button(action: {
                self.showImagePicker = true
            }, label: {
                Image(systemName: "camera.fill")
                    .resizable()
                    .frame(width: 40, height: 30)
            })
            if isAPICallOngoing {
                ProgressView("Please wait…")
            }
            VStack(alignment: .trailing) {
                HStack(alignment: .center, spacing: 6) {
                    Text("Name")
                    TextField("\(product?.name ?? WayAppPay.Product.defaultName)", text: $newName)
                        .textContentType(.name)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .center, spacing: 6) {
                    Text("Price")
                    TextField("\(WayAppPay.formatAmount(product?.price ?? 0))", text: $newPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding()
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .animation(.easeInOut(duration: 0.3))
            Spacer()
        }
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
        .font(.headline)
        .navigationBarTitle(
            newName.isEmpty ? (product?.name ?? "") : newName
        )
        .navigationBarItems(trailing:
            Button(action: {
                DispatchQueue.main.async {
                    self.isAPICallOngoing = true
                }
                if self.product == nil,
                   let merchantUUID = session.merchantUUID {
                    // creation
                    let newProduct = WayAppPay.Product(merchantUUID: merchantUUID, name: self.newName, price: self.newPrice)
                    WayAppPay.Product.add(merchantUUID: merchantUUID, product: newProduct, image: self.newImage) { product, error in
                        if let product = product {
                            DispatchQueue.main.async {
                                session.products.add(product)
                                self.apiCallCompleted(nil)
                            }
                        } else {
                            WayAppUtils.Log.message("Did not get product")
                        }
                    }
                } else {
                    // update
                    self.product?.update(name: self.newName, price: self.newPrice, image: self.newImage, completion: self.apiCallCompleted(_:))
                }
            }, label: { Text("Save") })
            .alert(isPresented: $showUpdateResultAlert) {
                Alert(title: Text("System error"),
                      message: Text("Product could not be updated. Try again later. If problem persists contact support@wayapp.com"),
                      dismissButton: .default(Text("OK")))
            }
        .disabled(shouldSaveButtonBeDisabled)
        )
        .sheet(isPresented: self.$showImagePicker) {
            PhotoCaptureView(showImagePicker: self.$showImagePicker, image: self.$newImage)
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayAppPay.Product(merchantUUID: "", name: "no name", price: "100"))
    }
}
