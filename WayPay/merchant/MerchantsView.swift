//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct MerchantsView: View {
    @State private var merchants = Container<WayPay.Merchant>()
    var customer: WayPay.Customer

    var body: some View {
            List {
                ForEach(merchants) { merchant in
                    NavigationLink(destination: MerchantAdminView(merchant: merchant)) {
                        Text(merchant.name ?? "no name")
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(merchant)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Merchants"), displayMode: .inline)
            .onAppear(perform: {
                load()
            })
    }
}

struct MerchantsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Merchants")
    }
}

extension MerchantsView {
    private func load() {
        if merchants.isEmpty {
            WayPay.Merchant.load { merchants, error in
                if let merchants = merchants {
                    self.merchants.setTo(merchants.filter {
                        return customer.customerUUID == $0.customerUUID
                    })
                } else {
                    Logger.message("No merchants found")
                }
            }
        }
    }
    
    private func delete(_ merchant: WayPay.Merchant) {
        WayPay.Merchant.delete(merchant.merchantUUID) { error in
            if let error = error {
                Logger.message(error.localizedDescription)
            } else {
                merchants.remove(merchant)
            }
        }
    }

    
}
