//
//  OnboardingView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var session: WayPay.Session
    @State private var currentTab = 0
    var fromSettings: Bool = false
    
    var body: some View {
        VStack {
            TabView(selection: $currentTab,
                    content:  {
                        OnboardingPageView(page: .ONE)
                            .tag(0)
                        OnboardingPageView(page: .TWO)
                            .tag(1)
                        OnboardingPageView(page: .THREE)
                            .tag(2)
                        OnboardingPageView(page: .FOUR)
                            .tag(3)
                        OnboardingPageView(page: .FIVE)
                            .tag(4)
                    })
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .padding(.horizontal)
            if !fromSettings && OnboardingPage.displayButton(tab: currentTab) {
                VStack {
                    Button(action: {
                        session.skipOnboarding = true
                        UserDefaults.standard.set(true, forKey: WayPay.DefaultKey.SKIP_ONBOARDING.rawValue)
                        UserDefaults.standard.synchronize()
                    }, label: {
                        Text("Get started")
                            .padding()
                    })
                    .buttonStyle(WayPay.WideButtonModifier())
                }
                .padding()
            }
        }
        .navigationBarTitle(Text("Tutorial"), displayMode: .inline)
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
