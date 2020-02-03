//
//  MerchantRowView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/3/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct MerchantRowView: View {
    
    //var merchant: WayAppPay.Merchant
    
    var body: some View {
        HStack {
            Text("Menchant")
            //ImageView(withURL: merchant.logo)
            //Text(verbatim: merchant.name ?? WayAppPay.Merchant.defaultName)
        }
    }
}

struct MerchantRowView_Previews: PreviewProvider {
    static var previews: some View {
        MerchantRowView()
    }
}
