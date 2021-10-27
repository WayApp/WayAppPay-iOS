//
//  ContentView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 11/24/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var session: WayPay.Session
    @State var navigationSelection: Int?
    
    var body: some View {
        if !session.skipOnboarding {
            return AnyView(OnboardingView())
        } else if session.showAuthenticationView {
            return AnyView(
                NavigationView {
                    AuthenticationView()
                })
        } else {
            return AnyView(
                NavigationView {
                    CheckoutView()
                })
        }
    }
    
    func optionsView() -> AnyView {
        return AnyView(
            VStack {
                Button {
                    self.navigationSelection = 0
                } label: {
                    Label(NSLocalizedString("Scan customer QR", comment: "CheckoutView: button title"), systemImage: "qrcode.viewfinder")
                        .padding()
                }
                .buttonStyle(WayPay.WideButtonModifier())
                .padding(.horizontal)
                NavigationLink(destination: CheckoutView(), tag: 0, selection: $navigationSelection) {
                    EmptyView()
                }
            }
            .onAppear(perform: {
                WayAppUtils.Log.message("****** onAppear")
                session.storeManager.validateAutoReneawableSubscriptions()
            })
        ) // AnyView
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(WayPay.session)
    }
}
