//
//  WayAppPayApp.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 16/2/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

@main
struct WayPayApp: App {
    
    init() {
        UITableView.appearance().backgroundColor = UIColor(named: "CornSilk")
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(WayPay.session)
                .accentColor(Color("MintGreen"))
        }
        .commands {
            SidebarCommands()
        }
    }
}
