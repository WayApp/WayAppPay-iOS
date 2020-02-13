//
//  UserMessages.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import UIKit

extension WayAppPay {
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
        case passwordChangeNotAvailable
        case pictureConfigurationFailed
        case forgotPassword(String)
        case forgotPasswordError(String)
        case shareOffer
        case shareMerchant
        case shareEvent
        case noSpeechRecognitionAvailable
        case merchantDoesNotHaveLoyaltyProgram
        case bankAccountAssociationOTPIsNotValid
        case bankAccountAssociationFailed
        case bankAccountIsAlreadyAssociated
        case ns_registrationNecessary

        static let cancelButton = NSLocalizedString("Cancelar", comment: "Alavuelta.Message: cancelButton")
        static let exitButton = NSLocalizedString("Salir", comment: "Alavuelta.Message: cancelButton")
        static let dismissButton = NSLocalizedString("OK", comment: "Alavuelta.Message: dismissButton")
        static let backButton = NSLocalizedString("Atrás", comment: "Alavuelta.Message: backButton")
        static let doneButton = NSLocalizedString("Hecho", comment: "Alavuelta.Message: doneButton")
        static let unspecified = NSLocalizedString("Sin especificar", comment: "Alavuelta.Message: do not wish to specify")
        static let close = NSLocalizedString("Cerrar", comment: "Alavuelta.Message: close")
        static let continueButton = NSLocalizedString("Continuar", comment: "Alavuelta.Message: continuar")
        static let online = NSLocalizedString("online", comment: "Alavuelta.Message: online")
        static let notAvailable = NSLocalizedString("no disponible", comment: "Alavuelta.Message: notAvailable")
        static let none = NSLocalizedString("Ninguno", comment: "Alavuelta.Message: none")
        static let expired = NSLocalizedString("caducada", comment: "Alavuelta.Message: expired")
        static let wantLoyaltyProgram = NSLocalizedString("¿Desea afiliarse al programa de fidelización?", comment: "Alavuelta.Message: wantLoyaltyProgram")

        var alert: (title: String, message: String) {
            switch self {
            case .error(let title, let text): return (title, text)
            case .titleAndText(let title, let text): return (title, text)
            case .closeTo(let title, let body): return (title, body)
            case .invalidEmail: return (NSLocalizedString("Dirección de correo no válida", comment: "User message: invalidEmail title"), NSLocalizedString("Introduce una dirección de correo válida para esta cuenta", comment: "User message: invalidEmail message"))
            case .invalidPassword: return (NSLocalizedString("Contraseña no válida", comment: "User message: invalidPassword title"), NSLocalizedString("Contraseña debe tener \(WayAppPay.Account.PINLength) caracteres", comment: "User message: password minimum length requirement"))
            case .passwordsDoNotMatch: return (NSLocalizedString("Contraseña no válida", comment: "User message: passwordsDoNotMatch title"), NSLocalizedString("La contraseña introducida en ambos campos debe ser idéntica", comment: "User message: passwords do not match"))
            case .confirmationEmailHelp(let email): return (NSLocalizedString("Código de confirmación", comment: "User message: confirmationEmailHelpTitle"), NSLocalizedString("El código de confirmación de 4 dígitos, fue enviado al correo \(email). Introdúcelo aquí para confirmar que lo recibiste", comment: "User message: confirmationEmailHelpMessage"))
            case .loginFailed: return (NSLocalizedString("No hemos podido iniciar sesión", comment: "User message: loginFailed title"), NSLocalizedString("Inténtalo de otro modo y si el problema no se soluciona contacta con nosotros en alavuelta@abanca.com", comment: "User message: Login error during authentication"))
            case .registrationFailed: return (NSLocalizedString("No hemos podido registrate", comment: "User message: registrationFailed title"), NSLocalizedString("Inténtalo con otro correo electrónico, y si el problema no se soluciona contacta con nosotros en alavuelta@abanca.com", comment: "User message: registrationFailed: registration error during registration"))
            case .passwordChangeFailed: return (NSLocalizedString("No hemos podido cambiar contraseña", comment: "User message: passwordChangeFailed title"), NSLocalizedString("Inténtalo con otra contraseña actual, y si el problema no se soluciona contacta con nosotros en alavuelta@abanca.com", comment: "User message: passwordChangeFailed: registration error during registration"))
            case .passwordChangeNotAvailable: return (NSLocalizedString("Cambio de contraseña no disponible", comment: "User message: passwordChangeNotAvailable title"), NSLocalizedString("Cambio de contraseña sólo es posible en sesiones con correo electrónico", comment: "User message: passwordChangeNotAvailable"))
            case .pictureConfigurationFailed: return (NSLocalizedString("No hemos podido actualizar tu avatar", comment: "User message: pictureConfigurationFailed title"), NSLocalizedString("Inténtalo con otra imagen, y si el problema no se soluciona contacta con nosotros en alavuelta@abanca.com", comment: "User message: pictureConfigurationFailed: registration error during registration"))
            case .forgotPassword(let email): return (NSLocalizedString("Para finalizar el cambio de contraseña", comment: "User message: forgotPassword title"), NSLocalizedString("Sigue las instrucciones enviadas a: ", comment: "User message: forgotPassword") + email)
            case .forgotPasswordError(let email): return (NSLocalizedString("Email no válido", comment: "User message: forgotPasswordError title"), NSLocalizedString("El email \(email) no está registrado", comment: "User message: forgotPasswordError"))
            case .shareOffer: return ("", NSLocalizedString("Te recomiendo revises esta oferta en la app \(WayAppPay.appName)", comment: "Alavuelta.Message: shareOffer"))
            case .shareMerchant: return ("", NSLocalizedString("Te recomiendo revises las ofertas de este establecimiento en la app \(WayAppPay.appName)", comment: "Alavuelta.Message: shareMerchant"))
            case .shareEvent: return ("", NSLocalizedString("Te recomiendo revises este evento en la app \(WayAppPay.appName)", comment: "Alavuelta.Message: shareEvent"))
            case .noSpeechRecognitionAvailable: return (NSLocalizedString("Voz", comment: "Alavuelta.Message: noSpeechRecognitionAvailable title"), NSLocalizedString("No es posible el reconocimiento de voz", comment: "Alavuelta.Message: noSpeechRecognitionAvailable"))
            case .merchantDoesNotHaveLoyaltyProgram: return (NSLocalizedString("Fideliza", comment: "Alavuelta.Message: merchantDoesNotHaveLoyaltyProgram title"), NSLocalizedString("Este establecimiento no tiene programa de fidelización", comment: "Alavuelta.Message: merchantDoesNotHaveLoyaltyProgram"))
            case .bankAccountAssociationOTPIsNotValid: return (NSLocalizedString("Clave no válida", comment: "User message: bankAccountAssociationOTPIsNotValid title"), NSLocalizedString("La clave introducida no coincide con la enviada", comment: "User message: bankAccountAssociationOTPIsNotValid"))
            case .bankAccountAssociationFailed: return (NSLocalizedString("No hemos podido asociar la cuenta", comment: "User message: bankAccountAssociationFailed title"), NSLocalizedString("Inténtalo de nuevo, y si el problema no se soluciona contacta con nosotros en alavuelta@abanca.com", comment: "User message: bankAccountAssociationFailed"))
            case .bankAccountIsAlreadyAssociated: return (NSLocalizedString("Cuenta asociada", comment: "User message: bankAccountIsAlreadyAssociated title"), NSLocalizedString("La cuenta ya se encuentra asociada", comment: "User message: bankAccountIsAlreadyAssociated"))
            case .ns_registrationNecessary: return (NSLocalizedString("Registro necesario", comment: "User message: ns_registration Necessary title"), NSLocalizedString("Inicia sesión y empieza a disfrutar de este servicio", comment: "User message: ns_registrationNecessary"))
            }
        }        
    }
}
