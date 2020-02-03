//
//  RememberUserView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/2/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct RememberUserView: View {
    
    @State var remember: Bool = false
    
    var body: some View {
        Toggle(isOn: $remember) {
                Text("Remember")
            }
    .padding()
    }
}

struct RememberUserView_Previews: PreviewProvider {
    static var previews: some View {
        RememberUserView()
    }
}
