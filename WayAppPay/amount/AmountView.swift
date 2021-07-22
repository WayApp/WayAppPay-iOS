//
//  AmountView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AmountView: View {
    @EnvironmentObject var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var amount: Double = 0
    @State private var total: Double = 0
    
    func numberEntered(number: Int) {
        if number < 10 {
            amount = (amount*10 + Double(number))
        } else {
            amount *= 100
        }
    }
    
    func delete() {
        amount = 0
    }
    
    private func resetAmountAndDescription() {
        amount = 0
        total = 0
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("CornSilk")
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .trailing) {
                    HStack {
                        Spacer()
                        Text(WayPay.currencyFormatter.string(for: Double((Double(amount) / 100)))!)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                            .onTapGesture {
                                self.delete()
                            }
                        Button(action: {
                            delete()
                        }, label: {
                            Label("Delete", systemImage: "delete.left")
                                .accessibility(label: Text("Delete"))
                        })
                        Spacer()
                    }
                    VStack {
                        HStack(spacing: 0) {
                            NumberButtonView(number: 1, completion: numberEntered)
                            NumberButtonView(number: 2, completion: numberEntered)
                            NumberButtonView(number: 3, completion: numberEntered)
                        }
                        HStack(spacing: 0) {
                            NumberButtonView(number: 4, completion: numberEntered)
                            NumberButtonView(number: 5, completion: numberEntered)
                            NumberButtonView(number: 6, completion: numberEntered)
                        }
                        HStack(spacing: 0) {
                            NumberButtonView(number: 7, completion: numberEntered)
                            NumberButtonView(number: 8, completion: numberEntered)
                            NumberButtonView(number: 9, completion: numberEntered)
                        }
                        HStack(spacing: 0) {
                            NumberButtonView(number: 100, completion: numberEntered)
                            NumberButtonView(number: 0, completion: numberEntered)
                            OperationButtonView(icon: "plus.circle") {
                                total += amount
                                amount = 0
                            }
                        }
                    }
                    HStack {
                        
                        Spacer()
                        Button {
                            if let merchantUUID = session.merchantUUID {
                                WayPay.session.shoppingCart.addProduct(WayPay.Product(merchantUUID: merchantUUID,
                                                                                            name: NSLocalizedString("Amount", comment: "Product name for entered amount"), description: NSLocalizedString("Entered amount", comment: "Product description for entered amount"), price: WayPay.formatAmount(Int((total + amount)*100 / 100))), isAmount: true)
                                self.resetAmountAndDescription()
                            }
                        } label: {
                            Label("Add to cart \(WayPay.formatPrice(Int((total + amount)*100 / 100)))", systemImage: "cart.badge.plus")
                                .accessibility(label: Text("Add to cart"))
                                .padding()
                                .foregroundColor(Color.white)
                        }
                        .buttonStyle(WayPay.ButtonModifier())
                        Spacer()
                    }
                    .buttonStyle(WayPay.ButtonModifier())
                    .padding()
                } // VStack
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .navigationBarTitle("Amount", displayMode: .inline)
        }
    }
}

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            AmountView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayPay.session)
    }
}
