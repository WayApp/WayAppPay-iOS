//
//  ShoppingCartView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ShoppingCartView: View {
    @EnvironmentObject private var session: WayPay.Session
 
    var body: some View {
        List {
            ForEach(session.shoppingCart.items) { item in
                ShoppingCartRowView(item: item)
            }
            .onDelete(perform: delete)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(WayPay.formatPrice(session.amount))
        .navigationBarItems(trailing:
            NavigationLink(destination: PaymentOptionsView()) {
                Image(systemName: "qrcode.viewfinder")
                .resizable()
                .frame(width: 30, height: 30, alignment: .center)
            }
            .foregroundColor(Color("MintGreen"))
            .aspectRatio(contentMode: .fit)
            .padding(.trailing, 16)
        )
    }
    
    func delete(at offsets: IndexSet) {
        session.shoppingCart.items.remove(at: offsets)
    }

}

struct ShoppingCartView_Previews: PreviewProvider {
    static var previews: some View {
        //ShoppingCartView()
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            ShoppingCartView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayPay.session)
    }
}
