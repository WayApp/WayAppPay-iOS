//
//  PaymentTokenRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct CardRowView: View {
        var card: WayAppPay.Card
        //var productIndex: Int

        var body: some View {
            HStack {
                HStack(alignment: .center, spacing: 3.0) {
                    Image(systemName: "creditcard")
                    VStack(alignment: .leading, spacing: 1.0) {
                        Text(card.alias ?? WayAppPay.Card.defaultName)
                        Text("\(WayAppPay.priceFormatter(card.balance?.balance ?? 0))")
                    }
                }
                Spacer()
            }
            .contentShape(Rectangle())
    }
}

struct CardRowView_Previews: PreviewProvider {
    static var previews: some View {
        CardRowView(card: WayAppPay.Card(issuerUUID: "1234", type: .POSTPAID, consent: nil, selectedIBAN: 0, limitPerOperation: 100000))
    }
}
