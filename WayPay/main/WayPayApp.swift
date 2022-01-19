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
    static var session = WayPayApp.Session()
    @AppStorage("skipOnboarding") static var skipOnboarding: Bool = UserDefaults.standard.bool(forKey: WayPay.DefaultKey.SKIP_ONBOARDING.rawValue)

    init() {
        UITableView.appearance().backgroundColor = UIColor.clear // Necessary for Light Mode removal of grayish background
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(WayPayApp.session)
                .accentColor(Color.green)
        }
        .commands { SidebarCommands() }
    }
}
