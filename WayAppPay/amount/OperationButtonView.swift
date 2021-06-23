//
//  OperationButtonView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/8/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct OperationButtonView: View {
    
    let icon: String
    var completion: () -> Void = { }
    
    var body: some View {
        Button(action: {
            self.completion()
        }, label:  {
            Label("", systemImage: icon)
                .accessibility(label: Text("Add to cart"))
        })
        .font(.largeTitle)
        .foregroundColor(.primary)
        .frame(minWidth: 100.0, idealWidth: 150.00, maxWidth: 300.0, minHeight: 40.0, idealHeight: 60.0, maxHeight: 80.0, alignment: .center)
        .border(Color.primary, width: 0.5)
    }
}

struct OperationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        OperationButtonView(icon: "delete.left")
    }
}
