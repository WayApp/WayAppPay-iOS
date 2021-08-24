//
//  BadgeView.swift
//  WayPay
//
//  Created by Oscar Anzola on 24/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct Badge: View {
    @EnvironmentObject var session: WayPay.Session

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            Text(String(session.shoppingCart.count))
                .font(.system(size: 16))
                .padding(5)
                .background(Color.red)
                .foregroundColor(Color.white)
                .clipShape(Circle())
                // custom positioning in the top-right corner
                .alignmentGuide(.top) { $0[.bottom] }
                .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
                .opacity(session.shoppingCart.count == 0 ? 0 : 1)
        }
    }
}
