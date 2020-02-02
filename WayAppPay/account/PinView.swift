//
//  PinView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/2/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct PinView: View {
    var body: some View {
        HStack {
            Image(systemName: "lock.rotation")
            TextField("Pin", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            Image(systemName: "eye.slash")
        }
        .padding()
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView()
    }
}
