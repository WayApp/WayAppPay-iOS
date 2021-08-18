//
//  Onboarding.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import Foundation

enum OnboardingPage: CaseIterable {
    case ONE, TWO, THREE
    
    var title: String {
        switch self {
        case .ONE: return "Reward your customers"
        case .TWO: return "Community features"
        case .THREE: return "Start using it"
        }
    }
    
    var image: String {
        switch self {
        case .ONE: return "Trophy"
        case .TWO: return "Rocket"
        case .THREE: return "Hand"
        }
    }
    
    var explanation: String {
        switch self {
        case .ONE: return "ONE: Now when we have created OnboardingData model we can start creating our OnboardingView"
        case .TWO: return "TWO: Now when we have created OnboardingData model we can start creating our OnboardingView"
        case .THREE: return "THREE: Now when we have created OnboardingData model we can start creating our OnboardingView"
        }
    }
    
    var displayButton: Bool {
        return self == .THREE
    }

}
