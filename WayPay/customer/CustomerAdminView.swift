//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct CustomerAdminView: View {
    var customer: WayPay.Customer

    var body: some View {
        Form {
            NavigationLink(destination:  IssuersView()) {
                Text("Issuers")
            }
            NavigationLink(destination:  MerchantsView()) {
                Text("Merchants")
            }
        }
        .navigationBarTitle(Text(customer.name ?? "no name"), displayMode: .inline)
    }
}

struct CustomerAdminView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Customer")
    }
}
