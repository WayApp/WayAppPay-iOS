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

    var product: WayAppPay.Product
    
    @State var newName: String = ""
    @State var newPrice: String = ""
    
    @State private var showImagePicker: Bool = false
    @State private var newImage: UIImage? = nil
    
    let imageSize: CGFloat = 180.0

    var shouldSaveButtonBeDisabled: Bool {
        return newName.isEmpty && newPrice.isEmpty && newImage == nil
    }
    
    private func updateCompleted(_ error: Error?) {
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
                ImageView(withURL: product.image, size: imageSize)
            } else {
                Image(uiImage:newImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
            }
            Button(action: {
                self.showImagePicker = true
            }, label: {
                Image(systemName: "camera.fill")
                    .resizable()
                    .frame(width: 40, height: 30)
            })
            .padding(.bottom, 30)
            VStack(alignment: .trailing, spacing: WayAppPay.UI.verticalSeparation) {
                HStack(alignment: .center, spacing: 12) {
                    Text("Name")
                    TextField("\(product.name ?? WayAppPay.Product.defaultName)", text: $newName)
                        .textContentType(.none)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .center, spacing: 12) {
                    Text("Price")
                    TextField("\(WayAppPay.priceFormatter(product.price))", text: $newPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .animation(.easeInOut(duration: 0.3))
            Spacer()
        }
        .gesture(DragGesture().onChanged({ _ in WayAppPay.hideKeyboard() }))
        .font(.headline)
        .padding()
        .navigationBarTitle(product.name ?? WayAppPay.Product.defaultName)
        .navigationBarItems(trailing:
            Button(action: {
                DispatchQueue.main.async {
                    self.isAPICallOngoing = true
                }
                self.product.update(name: self.newName, price: self.newPrice, image: self.newImage, completion: self.updateCompleted(_:))
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
        ProductDetailView(product: WayAppPay.Product(name: "no name", price: 100))
    }
}
