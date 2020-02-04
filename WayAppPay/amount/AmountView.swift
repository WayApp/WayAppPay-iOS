//
//  AmountView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AmountView: View {
    @State private var showScanner = false


    func handleScan(result: Result<String, ScannerView.ScanError>) {
       self.showScanner = false
    
       switch result {
       case .success(let code):
            print("Success. QR=\(code)")
       case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
       }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 8.0){
                Spacer()
                HStack(alignment: .center, spacing: 40.0) {
                    Text("0,00€")
                        .font(.largeTitle)
                        .foregroundColor(Color.black)
                        .fontWeight(.bold)
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .frame(width: 40, height: 25)
                            .foregroundColor(Color.black)
                    }
                }
                TextField("description", text:/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 16.0)
                VStack {
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 1)
                        NumberButtonView(button: 2)
                        NumberButtonView(button: 3)
                    }
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 4)
                        NumberButtonView(button: 5)
                        NumberButtonView(button: 6)
                    }
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 7)
                        NumberButtonView(button: 8)
                        NumberButtonView(button: 9)
                    }
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 100)
                        NumberButtonView(button: 0)
                        AddButtonView()
                    }
                }
            }
            .navigationBarTitle("Amount")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: { }, label: { Image(systemName: "cart.fill.badge.plus")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) })
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 16)
                    Button(action: {
                        self.showScanner = true
                    }, label: { Image(systemName: "qrcode.viewfinder")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center) })
                        .sheet(isPresented: $showScanner) {
                            VStack {
                                ScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: self.handleScan)
                                HStack {
                                    Text("Dismiss")
                                    Spacer()
                                    Button("Done") { self.showScanner = false }
                                }
                                .padding()
                            }
                    }
                }
            )
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
        .environmentObject(WayAppPay.session)
    }
}
