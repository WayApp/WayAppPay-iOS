//
//  AuthenticationView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        VStack {
            Image(/*@START_MENU_TOKEN@*/ /*@PLACEHOLDER=Image Name@*/"Image Name"/*@END_MENU_TOKEN@*/)
            UserView()
            PinView()
            RememberUserView()
            ForgotPinView()
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
