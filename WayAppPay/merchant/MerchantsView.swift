//
//  MerchantsView.swift
//  WayAppPay
//
//  Created by Silvana Pérez Leis on 2/3/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct MerchantsView: View {
    
     //@EnvironmentObject private var accountData: WayAppPay.Session.AccountData
    
    var body: some View {
        Text("Merchants")
        //List {
        //    ForEach(accountData.merchants) { merchant in
        //        NavigationLink(
        //            destination: ProductGalleryView()
        //        ) {
        //            MerchantRowView(merchant: merchant)
        //        }
        }
    
}
    


struct MerchantsView_Previews: PreviewProvider {
    static var previews: some View {
        MerchantsView()
    }
}
