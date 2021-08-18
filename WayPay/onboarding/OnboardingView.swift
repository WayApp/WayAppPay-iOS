//
//  OnboardingView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentTab = 0
    
    var body: some View {
        TabView(selection: $currentTab,
                content:  {
                    OnboardingPageView(page: .ONE)
                        .tag(0)
                    OnboardingPageView(page: .TWO)
                        .tag(1)
                    OnboardingPageView(page: .THREE)
                        .tag(2)
                })
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
