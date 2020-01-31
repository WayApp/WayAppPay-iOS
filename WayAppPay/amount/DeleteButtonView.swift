//
//  DeleteButtonView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct DeleteButtonView: View {
    var body: some View {
         Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 40, height: 25)
                    .foregroundColor(Color.black)
        }
    }
}

struct DeleteButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButtonView()
    }
}
