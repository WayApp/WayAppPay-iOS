//
//  OnboardingPageView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct OnboardingPageView: View {
    @EnvironmentObject var session: WayPay.Session

    var page: OnboardingPage = .ONE

    var body: some View {
        VStack {
            Image(page.image)
                .resizable()
                .scaledToFit()
            Text(page.title)
                .font(.title2)
                .bold()
            Text(page.explanation)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            if page.displayButton {
                Button(action: {
                    session.skipOnboarding = true
                    UserDefaults.standard.set(true, forKey: WayPay.DefaultKey.SKIP_ONBOARDING.rawValue)
                    UserDefaults.standard.synchronize()
                }, label: {
                    Text("Get Started")
                        .padding()
                })
                .buttonStyle(WayPay.WideButtonModifier())
            }
        }
        .padding()
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView()
    }
}
