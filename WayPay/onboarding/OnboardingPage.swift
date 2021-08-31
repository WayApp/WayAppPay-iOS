//
//  Onboarding.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

enum OnboardingPage: CaseIterable {
    case ONE, TWO, THREE, FOUR, FIVE
    
    var title: String {
        switch self {
        case .ONE: return NSLocalizedString("It is free", comment: "OnboardingPage: title")
        case .TWO: return NSLocalizedString("Reward customer visits", comment: "OnboardingPage: title")
        case .THREE: return NSLocalizedString("Premium features", comment: "OnboardingPage: title")
        case .FOUR: return NSLocalizedString("Onboard your customers", comment: "OnboardingPage: title")
        case .FIVE: return NSLocalizedString("Get started", comment: "OnboardingPage: title")
        }
    }
    
    var image: String {
        switch self {
        case .ONE: return "Peace"
        case .TWO: return "Trophy"
        case .THREE: return "Pig"
        case .FOUR: return "Rooster"
        case .FIVE: return "Hand"
        }
    }
    
    var explanation: String {
        switch self {
        case .ONE: return NSLocalizedString("Start using WayPay completely free. Contact us to enable premium features", comment: "OnboardingPage: explanation")
        case .TWO: return NSLocalizedString("Setup your digital punch card campaign in one-click. Choose the amount of visits and the reward (cashback or coupon)", comment: "OnboardingPage: explanation")
        case .THREE: return NSLocalizedString("You can also reward customers by how much they spend, and sell your own digital giftcard. Contact us", comment: "OnboardingPage: explanation")
        case .FOUR: return NSLocalizedString("In the Setting section you will find a QR that your customers can scan to install the loyalty card on the Wallet app of their phone (no app necessary)", comment: "OnboardingPage: explanation")
        case .FIVE: return NSLocalizedString("Remember, go to Settings to setup the punch card campaign, display the registration QR to your customers, and start scanning to reward them", comment: "OnboardingPage: explanation")
        }
    }
    
    var displayButton: Bool {
        return self == .FIVE
    }
    
    static func displayButton(tab: Int) -> Bool {
        return tab == OnboardingPage.allCases.count - 1
    }

}
