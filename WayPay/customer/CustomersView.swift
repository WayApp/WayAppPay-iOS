//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct CustomersView: View {
    @State private var customers = Container<WayPay.Customer>()

    var body: some View {
        List {
            ForEach(customers) { customer in
                NavigationLink(destination: CustomerAdminView(customer: customer)) {
                    Text(customer.name ?? "no name")
                }
            }
        }
        .navigationBarTitle(Text("Customers"), displayMode: .inline)
        .navigationBarItems(trailing:
                                NavigationLink(destination: NewCardView()) {
            Image(systemName: "plus.circle")
                .imageScale(.large)})
        .onAppear(perform: {
            load()
        })
    }
}

struct CustomersView_Previews: PreviewProvider {
    static var previews: some View {
        CustomersView()
    }
}

extension CustomersView {
    private func load() {
        if customers.isEmpty {
            WayPay.Customer.load { customers, error in
                DispatchQueue.main.async {
                    if let customers = customers {
                        self.customers.setTo(customers)
                    } else {
                        Logger.message("No customers found")
                    }
                }
            }
        }
    }
    
}
