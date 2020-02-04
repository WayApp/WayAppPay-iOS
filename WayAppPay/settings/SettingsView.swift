//
//  SettingsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

extension String: ContainerProtocol {
    var containerID: String {
        return self
    }
}

struct SettingsView: View {
    @EnvironmentObject var session: WayAppPay.Session

    var body: some View {
        if session.merchants.isEmpty {
            return AnyView(Text("There are no merchants"))
        } else {
            return AnyView(VStack {
                Text("Select merchant:")
                Picker(selection: $session.seletectedMerchant, label: Text("Please choose a merchant")) {
                    ForEach(0..<session.merchants.count) {
                        Text(self.session.merchants[$0].name ?? "SILVANA")
                    }
                }
                .labelsHidden()
                Text("Selected merchant: \(session.merchants[session.seletectedMerchant].name ?? "")")
                Button(action: {
                    self.session.logout()
                    DispatchQueue.main.async {
                    }

                }) {
                    Text("Logout")
                }
            }
            .padding())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
