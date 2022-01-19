//
//  WayPayAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct WayPayAdminView: View {
    var body: some View {
        Form {
            NavigationLink(destination: AccountAdminView()) {
                Label(NSLocalizedString("Account", comment: "WayPayAdminView: Account option"), systemImage: "questionmark.video")
            }
            NavigationLink(destination:  CardAdminView()) {
                Label(NSLocalizedString("Card", comment: "WayPayAdminView: Card option"), systemImage: "questionmark.video")
            }
            NavigationLink(destination:  IssuerAdminView()) {
                Label(NSLocalizedString("Issuer", comment: "WayPayAdminView: Issuer option"), systemImage: "questionmark.video")
            }
            NavigationLink(destination:  MerchantAdminView()) {
                Label(NSLocalizedString("Merchant", comment: "WayPayAdminView: Merchant option"), systemImage: "questionmark.video")
            }
        }
    }
}

struct WayPayAdminView_Previews: PreviewProvider {
    static var previews: some View {
        WayPayAdminView()
    }
}
