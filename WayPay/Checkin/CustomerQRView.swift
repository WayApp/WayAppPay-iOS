//
//  CheckoutQRView.swift
//  WayPay
//
//  Created by Oscar Anzola on 19/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CustomerQRView: View {
    @EnvironmentObject private var session: WayPay.Session
    
    var qr: UIImage {
        if let code = WayAppUtils.generateQR(from: "https://pay.staging.wayapp.com/sign-up") {
            return code
        } else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
    }
    
    var body: some View {
        VStack {
            Text("Your customers can scan this QR from any QR code reader and install their mobile Wallet pass")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Image(uiImage: qr)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }
        .padding()
        .navigationBarTitle(NSLocalizedString("Registration QR", comment: "CheckoutQRView title"))
        .navigationBarItems(trailing:
                                Button(action: {
                                    actionSheet()
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                }
        )
    }
    
    func actionSheet() {
        let activityVC = UIActivityViewController(activityItems: [qr], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }    
}

struct CustomerQRView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutQRView()
    }
}
