//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct IssuersView: View {
    @State private var issuers = Container<WayPay.Issuer>()
    var customer: WayPay.Customer

    var body: some View {
            List {
                ForEach(issuers) { issuer in
                    NavigationLink(destination: IssuerAdminView(customer: customer, issuer: issuer)) {
                        Text(issuer.name ?? "no name")
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationBarTitle(Text("Issuers"), displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: NewCardView()) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)})
            .onAppear(perform: {
                load()
            })
    }
}

struct IssuersView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Issuers")
    }
}

extension IssuersView {
    private func load() {
        if issuers.isEmpty {
            WayPay.Issuer.load { issuers, error in
                DispatchQueue.main.async {
                    if let issuers = issuers {
                        self.issuers.setTo(issuers)
                    } else {
                        Logger.message("No issuers found")
                    }
                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            WayPay.Issuer.delete(issuers[offset].issuerUUID) { error in
                if let error = error {
                    Logger.message(error.localizedDescription)
                } else {
                    issuers.remove(at: offset)
                }
            }
        }
    }

    
}
