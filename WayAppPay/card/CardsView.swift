//
//  PaymentTokenView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct CardsView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    
    var body: some View {
        NavigationView {
            List {
                ForEach(session.cards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) { CardRowView(card: card) }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Cards")
            .navigationBarItems(trailing:
                NavigationLink(destination: NewCardView()) {   Image(systemName: "plus.circle")
                        .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                }
                .foregroundColor(Color("WAP-Blue"))
                .aspectRatio(contentMode: .fit)
            )
        }
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
    }
}
