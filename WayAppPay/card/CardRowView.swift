//
//  PaymentTokenRowView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI
import PassKit

struct CardRowView: View {
        var pass: PKPass
        //var productIndex: Int

        var body: some View {
            HStack {
                HStack(spacing: 8.0) {
                    Image(uiImage: pass.icon)
                        .resizable()
                        .frame(width: 30, height: 30)
                    VStack(alignment: .leading, spacing: 1.0) {
                        Text(pass.alias ?? WayAppPay.Card.defaultName)
                        //Text("\(WayAppPay.priceFormatter(card.balance?.balance ?? 0))")
                    }
                }
                Spacer()
            }
            .contentShape(Rectangle())
    }
}

struct CardRowView_Previews: PreviewProvider {
    static var previews: some View {
        CardRowView(pass: PKPass())
    }
}
