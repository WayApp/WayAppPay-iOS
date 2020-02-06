//
//  ReportsView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var session: WayAppPay.Session

    var body: some View {
        Text("Reports")
    }
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}
