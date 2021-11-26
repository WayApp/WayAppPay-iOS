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
        case .ONE: return NSLocalizedString("Registration", comment: "OnboardingPage: title")
        case .TWO: return NSLocalizedString("It is free", comment: "OnboardingPage: title")
        case .THREE: return NSLocalizedString("Community QR", comment: "OnboardingPage: title")
        case .FOUR: return NSLocalizedString("Payment and loyalty", comment: "OnboardingPage: title")
        case .FIVE: return NSLocalizedString("Get started", comment: "OnboardingPage: title")
        }
    }
    
    var image: String {
        switch self {
        case .ONE: return "Account"
        case .TWO: return "Peace"
        case .THREE: return "CommunityQR"
        case .FOUR: return "Trophy"
        case .FIVE: return "Hand"
        }
    }
    
    var explanation: String {
        switch self {
        case .ONE: return NSLocalizedString("Setup your new account. To complete registration, you will need the Community Code given to you by the WayPay team. If you have questions contact us at support@wayapp.com", comment: "OnboardingPage: explanation")
        case .TWO: return NSLocalizedString("Start using WayPay completely free. Buying local is now eaiser, cheaper and more fun", comment: "OnboardingPage: explanation")
        case .THREE: return NSLocalizedString("Scan the Community QR from your customers' mobile phone. They need to register with the Community and install the QR on their mobile phone", comment: "OnboardingPage: explanation")
        case .FOUR: return NSLocalizedString("Introduce the amount of every purchase to charge or reward your customers", comment: "OnboardingPage: explanation")
        case .FIVE: return NSLocalizedString("Register and start scanning the Community QR", comment: "OnboardingPage: explanation")
        }
    }
    
    var displayButton: Bool {
        return self == .FIVE
    }
    
    static func displayButton(tab: Int) -> Bool {
        return tab == OnboardingPage.allCases.count - 1
    }

}
