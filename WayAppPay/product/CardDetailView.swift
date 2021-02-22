//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false
    @State private var action: Int? = 10

    var card: WayAppPay.Card?
    
    @State var newAlias: String = ""
    @State var newPrice: String = ""
    
    var shouldSaveButtonBeDisabled: Bool {
        if card == nil {
            // creation
            return newAlias.isEmpty || newPrice.isEmpty
        } else {
            // update
            return newAlias.isEmpty && newPrice.isEmpty
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
        VStack(alignment: .leading, spacing: WayAppPay.UI.verticalSeparation) {
            VStack(alignment: .trailing, spacing: WayAppPay.UI.verticalSeparation) {
                HStack(alignment: .center, spacing: 12) {
                    Text("Alias")
                    TextField("\(card?.alias ?? WayAppPay.Card.defaultName)", text: $newAlias)
                        .textContentType(.none)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .center, spacing: 12) {
                    Text("Price")
                    TextField("", text: $newPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button(action: {
                   // WayAppPay.session.afterBanks.getConsent(pan: "43ECC228-F99E-4DEB-A16F-E0B7E09A7A36", service: "sandbox", validUntil: "30-09-2020")
                    
                }) {
                    Text("Test get consent")
                }
                
                Picker(selection: $action, label: Text("What is your favorite color?")) {
                    Text("Grant").tag(0)
                    Text("Renew").tag(1)
                    Text("Cancel").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
                
            } // VStack
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .animation(.easeInOut(duration: 0.3))
            .onAppear(perform: {
                WayAppUtils.Log.message("********************** CardDetailView onAppear: WayAppPay.session.afterBanks.banks count=\(WayAppPay.session.banks.count)")
            })
            Spacer()
        }
        .gesture(DragGesture().onChanged { _ in WayAppPay.hideKeyboard() })
        .font(.headline)
        .padding()
        .navigationBarTitle(
            newAlias.isEmpty ? (card?.alias ?? "") : newAlias
        )
        .navigationBarItems(trailing:
            Button(action: {
                DispatchQueue.main.async {
                    self.isAPICallOngoing = true
                }
                if self.card == nil {
                    WayAppUtils.Log.message("********************** CARD IS NIL")
                } else {
                    // update
                    self.card?.edit(iban: "123456") { error in
                        if error != nil {
                            WayAppUtils.Log.message("********************** \(error!.localizedDescription)")
                        } else {
                            WayAppUtils.Log.message("********************** CARD EDITED SUCCESSFULLY")
                        }
                    }
                }
            }, label: { Text("Save") })
            .alert(isPresented: $showUpdateResultAlert) {
                Alert(title: Text("System error"),
                      message: Text("Card could not be updated. Try again later. If problem persists contact support@wayapp.com"),
                      dismissButton: .default(Text("OK")))
            }
        .disabled(shouldSaveButtonBeDisabled)
        )
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayAppPay.Product(name: "no name", price: 100))
    }
}
