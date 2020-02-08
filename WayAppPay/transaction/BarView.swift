//
//  BarView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/8/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct BarView: View {
    var value: CGFloat
    var cornerRadius: CGFloat
    
    let barMaxheight: CGFloat = 200.0
    
    var body: some View {
        VStack {
            ZStack (alignment: .bottom) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 2, height: barMaxheight)
                    .foregroundColor(.white)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: 2, height: value == 0 ? 1 : min(value, barMaxheight))
                    .foregroundColor(value == 0 ? .black : .green)
            }.padding(.bottom, 8)
        }
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        BarView(value: 300.0, cornerRadius: 8)
    }
}
