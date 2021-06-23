//
//  WayAppPayApp.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 16/2/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        WayAppUtils.Log.message("No code in AppDelegate for now. Could remove the AppDelegate from WayPayApp")
//        UINavigationBar.appearance().backgroundColor = UIColor(named: "CornSilk")
        return true
    }
}

@main
struct WayPayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(WayAppPay.session)
                .accentColor(Color("MintGreen"))
        }
        .commands {
            SidebarCommands()
        }
    }
}
