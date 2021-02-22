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
    var card: WayAppPay.Card
    
    var body: some View {
        Label {
            Text(card.alias ?? WayAppPay.Card.defaultName)
        }
        icon: {
            card.pkPass?.icon != nil ? Image(uiImage: card.pkPass!.icon) : Image(systemName: "qrcode")
        }
        .frame(height: 60)
    }
}

struct CardRowView_Previews: PreviewProvider {
    static var previews: some View {
        CardRowView(card: WayAppPay.Card())
    }
}
