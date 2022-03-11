//
//  MerchantAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct MerchantAdminView: View {
    var merchant: WayPay.Merchant

    var body: some View {
        Form {
            Button {
                DispatchQueue.main.async {
                    self.transactions()
                }
            } label: {
                Label("Transactions", systemImage: "trash")
            }
        }
    }
}

struct MerchantAdminView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Merchant")
    }
}

extension MerchantAdminView {
    private func transactions() {
    }


}
