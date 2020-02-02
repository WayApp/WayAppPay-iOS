//
//  UserView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/2/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct UserView: View {
    var body: some View {
         HStack {
            Image(systemName: "person.circle")
            TextField("User", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
         }
         .padding()
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
