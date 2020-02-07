//
//  ChangePinView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/7/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ChangePinView: View {
    @State private var currentPIN = String()
    @State private var newPIN = String()
    @State private var confirmationPIN = String()
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            TextField("Current PIN", text: $currentPIN)
            TextField("New PIN", text: $currentPIN)
            TextField("Re-enter new PIN", text: $currentPIN)
        }
        .padding()
        .foregroundColor(Color.black)
    }
}

struct ChangePinView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePinView()
    }
}
