//
//  MerchantAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct MerchantAdminView: View {
    var body: some View {
        Form {
            Button {
                DispatchQueue.main.async {
                    self.deleteMerchant()
                }
            } label: {
                Label("Delete merchant", systemImage: "trash")
            }
        }.navigationBarTitle(Text("Merchant"), displayMode: .inline)
    }
}

struct MerchantAdminView_Previews: PreviewProvider {
    static var previews: some View {
        MerchantAdminView()
    }
}

extension MerchantAdminView {
    private func deleteMerchant() {
        WayPay.Merchant.delete("5ce97cdd-1199-4a38-8f7c-da6cd4b5aaf9")
        WayPay.Merchant.delete("ca52512f-5b4b-4ec1-8ed0-898ce4e903e3")
    }


}
