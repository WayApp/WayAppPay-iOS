//
//  AmountView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct AmountView: View {
    var body: some View {
            VStack {
                Spacer()
                HStack {
                    DisplayView()
                    DeleteButtonView()
                }
                DescriptionView()
                //Divider()
                //    .frame(width: 300.0, height: 20.0, alignment: .center)
                //    .padding()
                Spacer()
                VStack {
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 1)
                        NumberButtonView(button: 2)
                        NumberButtonView(button: 3)
                    }
                    .frame(height: 100)
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 4)
                        NumberButtonView(button: 5)
                        NumberButtonView(button: 6)
                    }
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 7)
                        NumberButtonView(button: 8)
                        NumberButtonView(button: 9)
                    }
                    HStack(spacing: 0.0) {
                        NumberButtonView(button: 100)
                        NumberButtonView(button: 0)
                        AddButtonView()
                    }
                }
            }
    }
}

struct AmountView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            AmountView()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(WayAppPay.session)
    }
}
