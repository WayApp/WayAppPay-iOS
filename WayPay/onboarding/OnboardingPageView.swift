//
//  OnboardingPageView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct OnboardingPageView: View {
    var page: OnboardingPage = .ONE

    var body: some View {
        VStack {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
            Text(page.title)
                .font(.title2)
                .bold()
                .padding(.horizontal)
            Text(page.explanation)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.vertical)
        }
    }
}

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPageView()
    }
}
