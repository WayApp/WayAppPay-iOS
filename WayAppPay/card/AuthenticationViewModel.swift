//
//  AuthenticationModel.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 14/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import AuthenticationServices

extension WayAppPay {
    class AuthenticationViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return ASPresentationAnchor()
        }
            
        func signIn(consent: AfterBanks.ConsentResponse, completion: @escaping (Error?, AfterBanks.Consent?) -> Void) {
            WayAppUtils.Log.message("********************** CARD SIGNIN")
            guard let authURL = URL(string: consent.follow) else { return }
            let scheme = "WAP"
            
            // Initialize the session.
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { callbackURL, error in
                WayAppUtils.Log.message("COMPLETION: START")
                if let error = error {
                    WayAppUtils.Log.message("COMPLETION: ERROR")
                    WayAppUtils.Log.message(error.localizedDescription)
                }
                guard let callbackURL = callbackURL else {
                    WayAppUtils.Log.message(error?.localizedDescription ?? "Missing callbackURL")
                    return
                }
                WayAppUtils.Log.message("COMPLETION: OKAY")
                WayAppUtils.Log.message("callbackURL=\(callbackURL.absoluteString)")
                let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
                WayAppUtils.Log.message("queryItems=\(queryItems?.description ?? "NO QUERY ITEMS")")
                //  let token = queryItems?.filter({ $0.name == "token" }).first?.value
                WayAppPay.API.getConsentDetail(consent.consentId).fetch(type: [AfterBanks.Consent].self) { response in
                    if case .success(let response?) = response {
                        if let consents = response.result,
                            let consent = consents.first {
                            WayAppUtils.Log.message("******** CONSENT=\(consent)")
                            completion(nil, consent)
                        } else {
                            completion(WayAppPay.API.errorFromResponse(response), nil)
                            WayAppPay.API.reportError(response)
                        }
                    } else if case .failure(let error) = response {
                        completion(error, nil)
                        WayAppUtils.Log.message(error.localizedDescription)
                    }
                }
                
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }
}
