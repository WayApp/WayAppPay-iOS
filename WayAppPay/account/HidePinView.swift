//
//  HidePinView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/3/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct HidePinView: View {
    var body: some View {
        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
            Image(systemName: "eye.slash")
                .accentColor(Color.black)
        }
    }
}

struct HidePinView_Previews: PreviewProvider {
    static var previews: some View {
        HidePinView()
    }
}
