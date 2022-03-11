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
            NavigationLink(destination: AccountsView()) {
                Label(NSLocalizedString("Accounts", comment: "WayPayAdminView: Accounts option"), systemImage: "person.fill")
            }
            NavigationLink(destination:  CustomersView()) {
                Label(NSLocalizedString("Customers", comment: "WayPayAdminView: Customers option"), systemImage: "signature")
            }
        }
    }
}

struct WayPayAdminView_Previews: PreviewProvider {
    static var previews: some View {
        WayPayAdminView()
    }
}
