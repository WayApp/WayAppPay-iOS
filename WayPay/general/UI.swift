//
//  UserInterface.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI
import Combine

extension Color {
    static let offWhite = Color(red: 233 / 255, green: 242 / 255, blue: 252 / 255)
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func showKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
    }

}
#endif

struct UI {
    struct Constant {
        static let paymentResultSuccessImage = "checkmark.circle.fill"
        static let paymentResultFailureImage = "x.circle.fill"
        static let paymentResultImageSize: CGFloat = 220.0
        static let paymentResultDisplayDuration: TimeInterval = 1.5
        static let shoppingCartRowImageSize: CGFloat = 36.0
        static let buttonCornerRadius: CGFloat = 10.0
        static let buttonHeight: CGFloat = 50.0
        static let verticalSeparation: CGFloat = 16
        static let pinTextFieldWidth: CGFloat = 120
        static let cornerRadius: CGFloat = 36
    }

    struct Badge: View {
        let count: Int

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Color.clear
                Text(String(count))
                    .font(.system(size: 14))
                    .foregroundColor(Color.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    // custom positioning in the top-right corner
                    .alignmentGuide(.top) { $0[.bottom] }
                    .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
            }
        }
    }

    struct LazyView<Content: View>: View {
        let build: () -> Content
        init(_ build: @autoclosure @escaping () -> Content) {
            self.build = build
        }
        var body: Content {
            build()
        }
    }

    struct WayPayProgressViewStyle: ProgressViewStyle {
        func makeBody(configuration: Configuration) -> some View {
            ProgressView(configuration)
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
                .background(Color.green.opacity(0.25))
                .cornerRadius(8)
                .scaleEffect(x: 1.25, y: 1.25, anchor: .center)
        }
    }

    struct TextFieldModifier: ViewModifier {
        let padding: CGFloat // <- space between text and border
        let lineWidth: CGFloat

        func body(content: Content) -> some View {
            content
                .padding(padding)
                .overlay(RoundedRectangle(cornerRadius: padding)
                            .stroke(Color.primary, lineWidth: lineWidth)
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
                    .background(isEnabled ?
                                    (configuration.isPressed ? Color.orange : Color.green)
                                    : Color.gray)
                    .cornerRadius(UI.Constant.cornerRadius)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    struct StampButtonModifier: ButtonStyle {
        func makeBody(configuration: ButtonStyle.Configuration) -> some View {
            MyButton(configuration: configuration)
        }
        struct MyButton: View {
            let configuration: ButtonStyle.Configuration
            @Environment(\.isEnabled) private var isEnabled: Bool
            
            var body: some View {
                configuration.label
                    .font(.headline)
                    .background(isEnabled ?
                                    (configuration.isPressed ? Color.orange : Color.green)
                                    : Color.gray)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    struct WideButtonModifier: ButtonStyle {
        func makeBody(configuration: ButtonStyle.Configuration) -> some View {
            MyButton(configuration: configuration)
        }
        struct MyButton: View {
            let configuration: ButtonStyle.Configuration
            @Environment(\.isEnabled) private var isEnabled: Bool
            
            var body: some View {
                configuration.label
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .background(isEnabled ?
                                    (configuration.isPressed ? Color.orange : Color.green)
                                    : Color.gray)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            }
        }
    }

    struct CancelButtonModifier: ButtonStyle {
        func makeBody(configuration: ButtonStyle.Configuration) -> some View {
            MyButton(configuration: configuration)
        }
        struct MyButton: View {
            let configuration: ButtonStyle.Configuration
            @Environment(\.isEnabled) private var isEnabled: Bool
            
            var body: some View {
                configuration.label
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .background(isEnabled ?
                                    (configuration.isPressed ? Color.orange : .red)
                                    : Color.gray)
                    .cornerRadius(6)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
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
                            .foregroundColor(Color.black)
                    }
                    .padding(.trailing, 8)
                }
            }
        }
    }

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    static func formatPrice(_ price: Int?) -> String {
        if let price = price,
            let formatted = UI.currencyFormatter.string(for: Double(price) / 100) {
            return formatted
        }
        return ""
    }

    static func formatAmount(_ amount: Int?) -> String {
        if let amount = amount,
            let formatted = UI.amountFormatter.string(for: Double(amount) / 100) {
            return formatted
        }
        return ""
    }

    static let reportDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale.current
        return formatter
    }()

    static var displayDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    static var fullname: String {
        if let checkin = WayPayApp.session.checkin {
            return (checkin.firstName ?? "") + (checkin.lastName != nil ? " " + checkin.lastName! : "")
        }
        return ""
    }
    
    struct EditFieldHeader: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(Font.subheadline)
                .foregroundColor(Color.green)
        }
    }
}
