//
//  AuthenticationViewModel.swift
//  WayPay
//
//  Created by Oscar Anzola on 19/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import AuthenticationServices

extension WayPay {
    class AuthenticationViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return ASPresentationAnchor()
        }
            
        func signIn(consent: AfterBanks.ConsentResponse, completion: @escaping (Error?, AfterBanks.Consent?) -> Void) {
            Logger.message("********************** CARD SIGNIN")
            guard let authURL = URL(string: consent.follow) else { return }
            let scheme = "WAP"
            
            // Initialize the session.
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { callbackURL, error in
                Logger.message("COMPLETION: START")
                if let error = error {
                    Logger.message("COMPLETION: ERROR")
                    Logger.message(error.localizedDescription)
                }
                guard let callbackURL = callbackURL else {
                    Logger.message(error?.localizedDescription ?? "Missing callbackURL")
                    return
                }
                Logger.message("COMPLETION: OKAY")
                Logger.message("callbackURL=\(callbackURL.absoluteString)")
                let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                Logger.message("queryItems=\(queryItems?.description ?? "NO QUERY ITEMS")")
                //  let token = queryItems?.filter({ $0.name == "token" }).first?.value
                WayPay.API.getConsentDetail(consent.consentId).fetch(type: [AfterBanks.Consent].self) { response in
                    if case .success(let response?) = response {
                        if let consents = response.result,
                            let consent = consents.first {
                            Logger.message("******** CONSENT=\(consent)")
                            completion(nil, consent)
                        } else {
                            completion(WayPay.API.errorFromResponse(response), nil)
                            WayPay.API.reportError(response)
                        }
                    } else if case .failure(let error) = response {
                        completion(error, nil)
                        Logger.message(error.localizedDescription)
                    }
                }
                
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }
}
