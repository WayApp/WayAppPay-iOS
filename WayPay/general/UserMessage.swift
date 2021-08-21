//
//  UserMessages.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
    enum UserMessage {
        case error(String, String)
        case titleAndText(String, String)
        case closeTo(String, String)
        case invalidEmail
        case invalidPassword
        case passwordsDoNotMatch
        case confirmationEmailHelp(String)
        case loginFailed
        case registrationFailed
        case passwordChangeFailed
        case forgotPassword(String)
        case forgotPasswordError(String)
        case progressView

        var alert: (title: String, message: String) {
            switch self {
            case .error(let title, let text): return (title, text)
            case .titleAndText(let title, let text): return (title, text)
            case .closeTo(let title, let body): return (title, body)
            case .invalidEmail: return (NSLocalizedString("Invalid email address", comment: "User message: invalidEmail title"), NSLocalizedString("Enter a valid email address for this account", comment: "User message: invalidEmail message"))
            case .invalidPassword: return (NSLocalizedString("PIN not valid", comment: "User message: invalidPassword title"), NSLocalizedString("PIN must have \(WayPay.Account.PINLength) digits", comment: "User message: password minimum length requirement"))
            case .passwordsDoNotMatch: return (NSLocalizedString("PIN does not match", comment: "User message: passwordsDoNotMatch title"), NSLocalizedString("Both entered PINs must match", comment: "User message: passwords do not match"))
            case .confirmationEmailHelp(let email): return (NSLocalizedString("Confirmation code", comment: "User message: confirmationEmailHelpTitle"), NSLocalizedString("The 4-digit confirmation code was emailed to: \(email). Please enter it here", comment: "User message: confirmationEmailHelpMessage"))
            case .loginFailed: return (NSLocalizedString("Login attempt failed", comment: "User message: loginFailed title"), NSLocalizedString("Try again, if problem persists contact us at support@wayapp.com", comment: "User message: Login error during authentication"))
            case .registrationFailed: return (NSLocalizedString("Registration attempt failed", comment: "User message: registrationFailed title"), NSLocalizedString("Try another email address, if problem persists contact us at support@wayapp.com", comment: "User message: registrationFailed: registration error during registration"))
            case .passwordChangeFailed: return (NSLocalizedString("PIN was not changed", comment: "User message: passwordChangeFailed title"), NSLocalizedString("Try your current PIN again, if problem persists contact us at support@wayapp.com", comment: "User message: passwordChangeFailed: registration error during registration"))
            case .forgotPassword(let email): return (NSLocalizedString("To finish the PIN change", comment: "User message: forgotPassword title"), NSLocalizedString("Follow instructions emailed to: ", comment: "User message: forgotPassword") + email)
            case .forgotPasswordError(let email): return (NSLocalizedString("Email address not valid", comment: "User message: forgotPasswordError title"), NSLocalizedString("Email address \(email) is not registered", comment: "User message: forgotPasswordError"))
            case .progressView: return (NSLocalizedString("Processing...", comment: "ProgressView title message"),"")
            }
        }
    }
}
