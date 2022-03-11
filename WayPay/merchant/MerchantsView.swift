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

    var body: some View {
            List {
                ForEach(merchants) { merchant in
                    NavigationLink(destination: MerchantAdminView(merchant: merchant)) {
                        Text(merchant.name ?? "no name")
                    }
                }
                .onDelete(perform: delete)
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
                    self.merchants.setTo(merchants)
                } else {
                    Logger.message("No merchants found")
                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            WayPay.Merchant.delete(merchants[offset].merchantUUID) { error in
                if let error = error {
                    Logger.message(error.localizedDescription)
                } else {
                    merchants.remove(at: offset)
                }
            }
        }
    }

    
}
