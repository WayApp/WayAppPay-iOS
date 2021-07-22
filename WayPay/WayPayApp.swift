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
