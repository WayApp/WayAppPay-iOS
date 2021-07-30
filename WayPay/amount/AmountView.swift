//
//  AmountView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI


struct AmountView: View {
    
    enum DisplayOption {
        case charge, topup
        
        var title: String {
            switch self {
            case .charge: return NSLocalizedString("Charge", comment: "AmountViewOption title")
            case .topup: return NSLocalizedString("Top up", comment: "AmountViewOption title")
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .charge: return NSLocalizedString("Add to cart", comment: "AmountViewOption action buttonTitle")
            case .topup: return NSLocalizedString("Top up", comment: "AmountViewOption action buttonTitle")
            }
        }

    }

    @EnvironmentObject var session: WayPay.Session
    @SwiftUI.Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var amount: Double = 0
    @State private var total: Double = 0
    @State private var isAPICallOngoing = false
    @State private var showTransactionResult = false
    @State private var wasTransactionSuccessful = false
    var scannedCode: String? = nil
    var displayOption: DisplayOption = .charge
    
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
        
    var body: some View {
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
                            switch displayOption {
                            case .charge:
                                WayPay.session.shoppingCart.addProduct(WayPay.Product(merchantUUID: merchantUUID,
                                                                                            name: NSLocalizedString("Amount", comment: "Product name for entered amount"), description: NSLocalizedString("Entered amount", comment: "Product description for entered amount"), price: Int((total + amount)*100 / 100)), isAmount: true)
                            case .topup:
                                handleTopup()
                            }
                        }
                    } label: {
                        Text(displayOption.buttonTitle)
                            .accessibility(label: Text(displayOption.buttonTitle))
                            .padding()
                            .foregroundColor(Color.white)
                    }
                    .buttonStyle(WayPay.ButtonModifier())
                    Spacer()
                }
                .buttonStyle(WayPay.ButtonModifier())
                .padding()
            } // VStack
            .navigationBarTitle(displayOption.title)
            .background(Color("CornSilk"))
            .alert(isPresented: $showTransactionResult) {
                Alert(
                    title: Text(wasTransactionSuccessful ? "✅" : "🚫")
                        .foregroundColor(wasTransactionSuccessful ? Color.green : Color.red)
                        .font(.title),
                    message: Text(displayOption.buttonTitle + " " + (wasTransactionSuccessful ? "was successful" : "failed")),
                    dismissButton: .default(
                                    Text("OK"),
                                    action: dismissView)
                )
            }
        }
    }
    
    private func dismissView() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    private func transactionResult(accepted: Bool) {
        DispatchQueue.main.async {
            self.showTransactionResult = true
            self.wasTransactionSuccessful = accepted
        }
    }
    
    func handleTopup() {
        WayAppUtils.Log.message("Topping up: \(total)")
        guard let code = scannedCode else {
            WayAppUtils.Log.message("Missing session.merchantUUID or session.accountUUID")
            return
        }
        let topup = WayPay.PaymentTransaction(amount: Int(total + amount), token: code, type: .TOPUP)
        isAPICallOngoing = true
        WayPay.API.topup(topup).fetch(type: [WayPay.PaymentTransaction].self) { response in
            DispatchQueue.main.async {
                isAPICallOngoing = false
            }
            switch response {
            case .success(let response?):
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: SUCCESS")
                if let transactions = response.result,
                   let transaction = transactions.first {
                    DispatchQueue.main.async {
                        self.transactionResult(accepted: transaction.result == .ACCEPTED)
                        self.session.transactions.addAsFirst(transaction)
                    }
                } else {
                    WayAppUtils.Log.message("INVALID_SERVER_DATA")
                    self.transactionResult(accepted: false)
                }
            case .failure(let error):
                WayAppUtils.Log.message("++++++++++ WayAppPay.PaymentTransaction: FAILED")
                WayAppUtils.Log.message(error.localizedDescription)
                self.transactionResult(accepted: false)
            default:
                self.transactionResult(accepted: false)
                WayAppUtils.Log.message("INVALID_SERVER_DATA")
            }
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
