//
//  AddButtonView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AddButtonView: View {
    var body: some View {
         Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                   Text("+")
               }
               .foregroundColor(Color.black)
               .font(.largeTitle)
               .frame(minWidth: 100.0, idealWidth: 150.00, maxWidth: 300.0, minHeight: 40.0, idealHeight: 60.0, maxHeight: 80.0, alignment: .center)
               .background(Color.white)
               .border(Color.gray, width: 0.5)
    }
}

struct AddButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddButtonView()
    }
}
