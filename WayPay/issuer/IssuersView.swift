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
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(issuer)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Issuers"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: NewIssuerView(customer: customer)) {
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
        WayPay.Issuer.load { issuers, error in
            DispatchQueue.main.async {
                if let issuers = issuers {
                    self.issuers.setTo(issuers.filter {
                        return customer.customerUUID == $0.customerUUID
                    })
                } else {
                    Logger.message("No issuers found")
                }
            }
        }
    }
    
    private func delete(_ issuer: WayPay.Issuer) {
        WayPay.Issuer.delete(issuer.issuerUUID) { error in
            if let error = error {
                Logger.message(error.localizedDescription)
            } else {
                issuers.remove(issuer)
            }
        }
    }

    
}
