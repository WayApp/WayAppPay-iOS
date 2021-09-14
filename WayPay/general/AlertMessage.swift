//
//  UserMessages.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
    enum AlertMessage {
        case error(String, String)
        case titleAndText(String, String)
        case closeTo(String, String)
        case invalidEmail
        case invalidPIN
        case pinsDontMatch
        case confirmationEmailHelp(String)
        case loginFailed
        case registrationFailed
        case pinChangeFailed
        case forgotPIN(String)
        case forgotPINerror(String)
        case premiumFeature
        case needsSetup
        case refund(Bool)
        case transaction(Bool)
        case addProducts
        case shoppingCartEmpty
        case requestGiftcard
        case requestPoints
        case consumerAccountCreationError
        case consumerAccountCreationSuccess
        case accountWithoutMerchants


        var text: (title: String, message: String) {
            switch self {
            case .error(let title, let text): return (title, text)
            case .titleAndText(let title, let text): return (title, text)
            case .closeTo(let title, let body): return (title, body)
            case .invalidEmail: return (NSLocalizedString("Invalid email address", comment: "User message: invalidEmail title"), NSLocalizedString("Enter a valid email address for this account", comment: "User message: invalidEmail message"))
            case .invalidPIN: return (NSLocalizedString("PIN not valid", comment: "User message: invalidPassword title"), NSLocalizedString("PIN must be", comment: "User message: pin minimum length requirement") + " " + WayPay.Account.PINLength.description + " " + NSLocalizedString("digits", comment: "User message: pin minimum length requirement"))
            case .pinsDontMatch: return (NSLocalizedString("PIN does not match", comment: "User message: pinsDontMatch title"), NSLocalizedString("Both entered PINs must match", comment: "User message: pins do not match"))
            case .confirmationEmailHelp(let email): return (NSLocalizedString("Confirmation code", comment: "User message: confirmationEmailHelpTitle"), NSLocalizedString("The 4-digit confirmation code was emailed to: \(email). Please enter it here", comment: "User message: confirmationEmailHelpMessage"))
            case .loginFailed: return (NSLocalizedString("Login attempt failed", comment: "User message: loginFailed title"), NSLocalizedString("Try again, if problem persists contact us at support@wayapp.com", comment: "User message: Login error during authentication"))
            case .registrationFailed: return (NSLocalizedString("Registration attempt failed", comment: "User message: registrationFailed title"), NSLocalizedString("Try another email address, if problem persists contact us at support@wayapp.com", comment: "User message: registrationFailed: registration error during registration"))
            case .pinChangeFailed: return (NSLocalizedString("PIN not changed", comment: "User message: pinChangeFailed title"), NSLocalizedString("Try your current PIN again, if problem persists contact us at support@wayapp.com", comment: "User message: pinChangeFailed: registration error during registration"))
            case .forgotPIN(let email): return (NSLocalizedString("To finish PIN change", comment: "User message: forgotPIN title"), NSLocalizedString("Follow instructions emailed to" + ": ", comment: "User message: forgotPIN") + email)
            case .forgotPINerror(let email): return (NSLocalizedString("Email not found", comment: "User message: forgotPINerror title"), NSLocalizedString("Email \(email) is not registered", comment: "User message: forgotPINerror"))
            case .premiumFeature: return (NSLocalizedString("Premium feature", comment: "User message: needsSetup"), NSLocalizedString("Contact sales@wayapp.com to enable", comment: "User message: needsSetup"))
            case .needsSetup: return (NSLocalizedString("Premium feature", comment: "User message: needsSetup"), NSLocalizedString("Contact sales@wayapp.com to enable", comment: "User message: needsSetup"))
            case .refund(let success):
                return (SingleMessage.success(success).text, success ? NSLocalizedString("Refund was successful", comment: "User message: refund result") :
                        NSLocalizedString("Refund failed", comment: "User message: refund result"))
            case .transaction(let success):
                return (SingleMessage.success(success).text, success ? NSLocalizedString("Transaction was successful", comment: "User message: Transaction result") :
                            NSLocalizedString("Transaction failed", comment: "User message: Transaction result"))
            case .addProducts: return (NSLocalizedString("Product catalogue empty", comment: "User message: addProducts"), NSLocalizedString("Go to Settings and add your products", comment: "User message: addProducts"))
            case .shoppingCartEmpty: return (NSLocalizedString("Shopping cart empty", comment: "User message: addProducts"), NSLocalizedString("Add products to the order", comment: "User message: addProducts"))
            case .requestGiftcard: return (NSLocalizedString("My own giftcard", comment: "User message: requestGiftcard"), NSLocalizedString("Hello, I am interested in selling my own digital rechargable giftcard. Please contact me. Thanks.", comment: "User message: requestGiftcard"))
            case .requestPoints: return (NSLocalizedString("Reward by € consumption", comment: "User message: requestPoints"), NSLocalizedString("Hello, I am interested in using this feature. Please contact me. Thanks.", comment: "User message: requestPoints"))
            case .consumerAccountCreationError: return (NSLocalizedString("Registration error", comment: "User message: consumerAccountCreationError"), NSLocalizedString("Email already registered, try a different email. If problem continues, contact support@wayapp.com", comment: "User message: consumerAccountCreationError"))
            case .consumerAccountCreationSuccess: return (NSLocalizedString("Account created", comment: "User message: consumerAccountCreationSuccess"), NSLocalizedString("Email sent to customer with QR to install on the phone", comment: "User message: consumerAccountCreationSuccess"))
            case .accountWithoutMerchants: return (NSLocalizedString("Login failed", comment: "User message: accountWithoutMerchants"), NSLocalizedString("App only available to registered merchants. Register a merchant and try again", comment: "User message: accountWithoutMerchants"))
            }
        }
    }
    
    enum SingleMessage {
        case progressView
        case success(Bool)
        case OK
        case requestGiftcard
        case requestPoints

        var text: String {
            switch self {
            case .progressView: return NSLocalizedString("Processing...", comment: "SingleMessage: ProgressView text")
            case .success(let success): return success ? "✅" : "🚫"
            case .OK: return NSLocalizedString("OK", comment: "SingleMessage: OK text")
            case .requestGiftcard: return NSLocalizedString("mailto:sales@wayapp.com?subject=My own giftcard&body=Hello, I am interested in selling my own digital rechargable giftcard. Please contact me. Thanks.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, comment: "SingleMessage: requestGiftcard")
            case .requestPoints: return NSLocalizedString("mailto:sales@wayapp.com?subject=Reward by € consumption&body=Hello, I am interested in using this feature. Please contact me. Thanks.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, comment: "SingleMessage: requestPoints")
            }
        }
    }
}
