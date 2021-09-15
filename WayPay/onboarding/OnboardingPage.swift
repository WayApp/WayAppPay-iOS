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
        case .ONE: return NSLocalizedString("Reward customer visits", comment: "OnboardingPage: title")
        case .TWO: return NSLocalizedString("It is free", comment: "OnboardingPage: title")
        case .THREE: return NSLocalizedString("Premium features", comment: "OnboardingPage: title")
        case .FOUR: return NSLocalizedString("Onboard your customers", comment: "OnboardingPage: title")
        case .FIVE: return NSLocalizedString("Get started", comment: "OnboardingPage: title")
        }
    }
    
    var image: String {
        switch self {
        case .ONE: return "Trophy"
        case .TWO: return "Peace"
        case .THREE: return "Pig"
        case .FOUR: return "Rooster"
        case .FIVE: return "Hand"
        }
    }
    
    var explanation: String {
        switch self {
        case .ONE: return NSLocalizedString("Setup your digital punch card campaign in one-click. Choose the amount of visits and the reward (cashback or coupon)", comment: "OnboardingPage: explanation")
        case .TWO: return NSLocalizedString("Start using WayPay completely free. Contact us to enable premium features", comment: "OnboardingPage: explanation")
        case .THREE: return NSLocalizedString("You can also reward customers by how much they spend, and sell your own digital giftcard. Contact us", comment: "OnboardingPage: explanation")
        case .FOUR: return NSLocalizedString("In the Setting section you can register your customers directly. You can also print the registration QR for customers to scan and self-register", comment: "OnboardingPage: explanation")
        case .FIVE: return NSLocalizedString("Start by going to Settings to setup your first punch card campaign, register your customers, and start scanning to reward them", comment: "OnboardingPage: explanation")
        }
    }
    
    var displayButton: Bool {
        return self == .FIVE
    }
    
    static func displayButton(tab: Int) -> Bool {
        return tab == OnboardingPage.allCases.count - 1
    }

}
