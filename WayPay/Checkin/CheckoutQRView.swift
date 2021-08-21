//
//  CheckoutQRView.swift
//  WayPay
//
//  Created by Oscar Anzola on 19/8/21.
//  Copyright © 2021 WayApp. All rights reserved.
//

import SwiftUI

struct CheckoutQRView: View {
    @EnvironmentObject private var session: WayPay.Session
    
    var qr: UIImage {
        if let merchantUUID = session.merchantUUID,
           let accountUUID = session.accountUUID,
           let code = WayAppUtils.generateQR(from: "\(merchantUUID)#\(accountUUID)") {
            return code
        } else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
    }
    
    var body: some View {
        VStack {
            Text("Your customers can scan this QR directly from their mobile Wallet pass to make payment")
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
        .navigationBarTitle(NSLocalizedString("Checkout QR", comment: "CheckoutQRView title"))
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

struct CheckoutQRView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutQRView()
    }
}
