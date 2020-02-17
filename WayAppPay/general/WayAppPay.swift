//
//  WayAppPay.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import AVFoundation
import SwiftUI
import Combine

struct WayAppPay {
    
    struct UI {
        static let paymentResultSuccessImage = "checkmark.circle.fill"
        static let paymentResultFailureImage = "x.circle.fill"
        static let paymentResultImageSize: CGFloat = 220.0
        static let paymentResultDisplayDuration: TimeInterval = 1.5
        static let shoppingCartRowImageSize: CGFloat = 36.0
        static let buttonCornerRadius: CGFloat = 10.0
        static let buttonHeight: CGFloat = 50.0
        static let verticalSeparation: CGFloat = 16
        static let pinTextFieldWidth: CGFloat = 120
    }
    
    class KeyboardObserver: ObservableObject {

      private var cancellable: AnyCancellable?

      @Published private(set) var keyboardHeight: CGFloat = 0

      let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }

      let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ -> CGFloat in 0 }

      init() {
        cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
          .subscribe(on: RunLoop.main)
          .assign(to: \.keyboardHeight, on: self)
      }
    }
    
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    struct ClearButton: ViewModifier {
        @Binding var text: String
         
        public func body(content: Content) -> some View {
            ZStack(alignment: .trailing) {
                content
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""})
                    {
                        Image(systemName: "multiply.circle")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                    .padding(.trailing, 8)
                }
            }
        }
    }

    static let acceptedPaymentCodes: [AVMetadataObject.ObjectType] = [.qr, .code128]

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.current
        formatter.numberStyle = .currencyAccounting
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    static func priceFormatter(_ price: Int?) -> String {
        if let price = price,
            let formatted = WayAppPay.currencyFormatter.string(for: Double(price) / 100) {
            return formatted
        }
        return ""
    }

    static let reportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale.current
        return formatter
    }()

    static let appName = "WayApp Pay"

    struct Constant {
    }

}
