//
//  NumberButtonView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/8/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct NumberButtonView: View {
    
    let number: Int
    var completion: (Int) -> Void = { i in }
    
    var body: some View {
        Button(action: {
            self.completion(self.number)
        }) {
            number == 100 ? Text("00") : Text(number.description)
        }
        .font(.largeTitle)
        .frame(minWidth: 100.0, idealWidth: 150.00, maxWidth: 300.0, minHeight: 40.0, idealHeight: 60.0, maxHeight: 80.0, alignment: .center)
        .border(Color.gray, width: 0.5)
    }
}

struct NumberButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NumberButtonView(number: 1)
    }
}
