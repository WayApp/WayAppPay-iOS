//
//  ShoppingCartView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ShoppingCartView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    
    var body: some View {
        NavigationView {
            List {
                ForEach(session.shoppingCart.items) { item in
                    ShoppingCartRowView(item: item)
                }
                .onDelete(perform: delete)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Products")
            .navigationBarItems(trailing:
                Button(action: { }, label: { Image(systemName: "qrcode.viewfinder")
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center) })
                    .aspectRatio(contentMode: .fit)
                    .padding(.trailing, 16)
            )
        }
    }
    
    func delete(at offsets: IndexSet) {
        session.shoppingCart.items.remove(at: offsets)
    }


}

struct ShoppingCartView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartView()
    }
}
