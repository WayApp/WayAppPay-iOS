//
//  DisplayView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct DisplayView: View {
    var body: some View {
        HStack {
            Text("0,00€")
                .font(.largeTitle)
                .foregroundColor(Color.black)
                .fontWeight(.bold)
            }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
