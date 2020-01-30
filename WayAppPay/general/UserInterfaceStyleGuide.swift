//
//  UserInterfaceStyleGuide.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension UIColor {
    // Background
    static var contentBackground: UIColor { return UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0) } // F7F7F7
    // Text
    static var primaryText: UIColor { return UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0) } // 222222
    static var secondaryText: UIColor { return UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) } // 666666
    // Button
    static var blueButtonBackground: UIColor { return UIColor(red: 91/255, green: 135/255, blue: 218/255, alpha: 1.0) } // 5B87DA
    // Main colors
    static var wayAppPayBlue: UIColor { return UIColor(red: 79/255, green: 118/255, blue: 189/255, alpha: 1.0) } // 036F90
    static var wayAppPayGrey: UIColor { return UIColor(red: 0/255, green: 177/255, blue: 148/255, alpha: 1.0) } // 676767
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
