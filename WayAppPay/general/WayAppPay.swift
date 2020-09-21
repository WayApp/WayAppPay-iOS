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
import PassKit
extension Color {
    static let offWhite = Color(red: 233 / 255, green: 242 / 255, blue: 252 / 255)
}

extension PKPass {
    var alias: String? {
        if let userInfo = self.userInfo as? [String : String],
        let alias = userInfo["alias"] {
            return alias
        }
        return nil
    }
    
    var pan: String? {
        if let userInfo = self.userInfo as? [String : String],
        let pan = userInfo["pan"] {
            return pan
        }
        return nil
    }
}

struct WayAppPay {
    struct LazyView<Content: View>: View {
        let build: () -> Content
        init(_ build: @autoclosure @escaping () -> Content) {
            self.build = build
        }
        var body: Content {
            build()
        }
    }

    struct TextFieldModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Color.offWhite)
                .cornerRadius(15)
                .foregroundColor(.black)
                .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black.opacity(0.05),lineWidth: 4)
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: 5, y: 5)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: -5, y: -5)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                )
        }
    }
    
    struct ButtonModifier: ButtonStyle {
        func makeBody(configuration: ButtonStyle.Configuration) -> some View {
            MyButton(configuration: configuration)
        }

        struct MyButton: View {
            let configuration: ButtonStyle.Configuration
            @Environment(\.isEnabled) private var isEnabled: Bool
            
            var body: some View {
                configuration.label
                    .font(.headline)
                    .background(isEnabled ? Color.green : Color.gray)
                    .cornerRadius(15)
                    .overlay(
                        VStack {
                            if configuration.isPressed {
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black.opacity(0.05),lineWidth: 4)
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: -5, y: -5)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(color: Color.black.opacity(0.2), radius: 3, x: -5, y: -5)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))

                            }
                        }
                    )
                    .shadow(color: Color.black.opacity(configuration.isPressed ? 0 : 0.2), radius: 5, x: -5, y: -5)
                    .shadow(color: Color.white.opacity(configuration.isPressed ? 0 : 0.6), radius: 5, x: -5, y: -5)
            }
        }
    }
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
    
    struct ActivityIndicator: UIViewRepresentable {
        var isAnimating: Bool
        var configuration = { (indicator: UIActivityIndicatorView) in }

        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
            UIActivityIndicatorView(style: .large)
        }
        
        func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
            isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
            configuration(uiView)
        }
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
