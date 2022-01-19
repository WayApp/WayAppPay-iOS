//
//  CardRowView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI
import PassKit

struct CardRowView: View {
    var card: WayPay.Card
    
    var body: some View {
        Label {
            Text(card.alias ?? WayPay.Card.defaultName) +
            Text(" ") +
            Text("(\(card.getType().title))").font(.footnote)
        }
        icon: {
            card.pkPass?.icon != nil ? Image(uiImage: card.pkPass!.icon) : Image(systemName: "qrcode")
        }
        .frame(height: 60)
    }
}

struct CardRowView_Previews: PreviewProvider {
    static var previews: some View {
        CardRowView(card: WayPay.Card())
    }
}
