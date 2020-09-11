//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI
import AuthenticationServices

class AuthenticationViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func signIn(consent: AfterBanks.ConsentResponse) {
        guard let authURL = URL(string: consent.follow) else { return }
        let scheme = "WAP"
        
        // Initialize the session.
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme) { callbackURL, error in
            WayAppUtils.Log.message("COMPLETION:")
            if let error = error {
                WayAppUtils.Log.message(error.localizedDescription)
            }
            guard let callbackURL = callbackURL else {
                WayAppUtils.Log.message(error?.localizedDescription ?? "Missing callbackURL")
                return
            }
            WayAppUtils.Log.message("callbackURL=\(callbackURL.absoluteString)")
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            WayAppUtils.Log.message("queryItems=\(queryItems?.description ?? "NO QUERY ITEMS")")
            //  let token = queryItems?.filter({ $0.name == "token" }).first?.value
            
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }

}

struct NewCardView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false
    @State private var action: Int? = 10
    @State private var selectedCardType = 0
    @State var authenticationViewModel = AuthenticationViewModel()

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()


        // make sure the following are the same as that used in the API
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale.current

        return formatter
    }()

    @State private var validUntil: Date = Calendar.current.date(byAdding: DateComponents(month: 3), to: Date()) ?? Date()
    
    let currencies = ["EUR", "USD", "VEF"]
    @State var selectedCurrency: Int = 0
    @State var alias: String = ""
    @State var iban: String = ""
    @State var selectedIssuer: Int = 0
    @State var selectedBank: Int = 0

    var shouldSaveButtonBeDisabled: Bool {
        return alias.isEmpty
    }
        
    private func apiCallCompleted(_ error: Error?) {
        DispatchQueue.main.async {
            self.isAPICallOngoing = false
            if error != nil {
                self.showUpdateResultAlert = true
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func postpaidOptions() -> some View {
        return VStack(alignment: .leading, spacing: WayAppPay.UI.verticalSeparation) {
            DatePicker(selection: $validUntil, displayedComponents: .date) {
                Text("Consent valid until")
            }
            Picker(selection: $selectedBank, label: Text("Bank")) {
                ForEach(0..<session.afterBanks.banks.count) {
                    Text(self.session.afterBanks.banks[$0].fullname ?? self.session.afterBanks.banks[$0].service)
                }
            }
            HStack(alignment: .center, spacing: 12) {
                Text("IBAN")
                TextField("account IBAN", text: $iban)
                    .textContentType(.none)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Button(action: {
                DispatchQueue.main.async {
                    self.isAPICallOngoing = true
                }
            }, label: { Text("Grant consent") })
        } // VStack
    } // func
    
    /*
    private func postpaidOptions() -> some View {
        return VStack(alignment: .leading, spacing: WayAppPay.UI.verticalSeparation) {
            VStack(alignment: .trailing, spacing: WayAppPay.UI.verticalSeparation) {
                DatePicker(selection: $validUntil, in: ...Date(), displayedComponents: .date) {
                    Text("Consent valid until")
                }
                Text("Date is \(validUntil, formatter: dateFormatter)")
                Button(action: {
                    WayAppPay.session.afterBanks.getConsent(pan: "43ECC228-F99E-4DEB-A16F-E0B7E09A7A36", service: "sandbox", validUntil: "30-09-2020")
                    
                }) {
                    Text("Test get consent")
                }
                Picker(selection: $action, label: Text("What is your favorite color?")) {
                    Text("Grant").tag(0)
                    Text("Renew").tag(1)
                    Text("Cancel").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
            } // VStack 2
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .animation(.easeInOut(duration: 0.3))
        } // VStack 1
        .gesture(DragGesture().onChanged { _ in WayAppPay.hideKeyboard() })
        .font(.headline)
        .padding()

    }
    */
    
    private func prepaidOptions() -> some View {
        return Picker(selection: $selectedCurrency, label: Text("Currency")) {
            ForEach(0..<currencies.count, id: \.self) {
                Text(self.currencies[$0])
            }
        }
    }
    
    private func createCard() {
        DispatchQueue.main.async {
            self.isAPICallOngoing = true
        }
        switch WayAppPay.Card.PaymentFormat.allCases[selectedCardType] {
        case .PREPAID:
            WayAppPay.Card.create(alias: self.alias, type: .POSTPAID) { error, card in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showUpdateResultAlert = true
                        self.isAPICallOngoing = false
                        WayAppUtils.Log.message("********************** \(error.localizedDescription)")
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                        WayAppUtils.Log.message("********************** CARD CREATION SUCCESSFULLY")
                    }
                }
            }
        case .POSTPAID:
            WayAppPay.Card.create(alias: self.alias, type: .POSTPAID) { error, card in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showUpdateResultAlert = true
                        self.isAPICallOngoing = false
                        WayAppUtils.Log.message("********************** \(error!.localizedDescription)")
                    }
                } else if let card = card, let accountUUID = self.session.accountUUID {
                    WayAppUtils.Log.message("********************** CARD CREATION SUCCESSFULLY")
                    self.session.afterBanks.getConsent(accountUUID: accountUUID, pan: card.pan,
                                                     //  service: self.session.afterBanks.banks[self.selectedBank].service,
                                                       service: "sandbox",
                                                       validUntil: self.dateFormatter.string(from: self.validUntil)) {error, consent in
                                                        if let error = error {
                                                            WayAppUtils.Log.message("********************** \(error.localizedDescription)")
                                                        } else if let consent = consent {
                                                            self.authenticationViewModel.signIn(consent: consent)
                                                        }
                    }
                }
            }
        case .CREDIT:
            break;
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General")) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("Alias")
                        TextField("alias", text: $alias)
                            .textContentType(.none)
                            .keyboardType(.default)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Picker(selection: $selectedIssuer, label: Text("Issuer")) {
                        ForEach(0..<session.issuers.count, id: \.self) {
                            Text(self.session.issuers[$0].name)
                        }
                    }
                    Picker(selection: $selectedCardType, label: Text("Type")) {
                        ForEach(0..<WayAppPay.Card.PaymentFormat.allCases.count, id: \.self) {
                            Text(WayAppPay.Card.PaymentFormat.allCases[$0].rawValue)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                if WayAppPay.Card.PaymentFormat.allCases[selectedCardType] == .PREPAID {
                    Section(header: Text("Prepaid")) {
                        prepaidOptions()
                    }
                }
                if WayAppPay.Card.PaymentFormat.allCases[selectedCardType] == .POSTPAID {
                    Section(header: Text("Bank account")) {
                        postpaidOptions()
                    }
                }
            }
            .navigationBarTitle(Text("New card"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.createCard()
                }, label: { Text("Save") })
                .alert(isPresented: $showUpdateResultAlert) {
                    Alert(title: Text("System error"),
                          message: Text("Card could not be created. Try again later. If problem persists contact support@wayapp.com"),
                          dismissButton: .default(Text("OK")))
                }
            .disabled(shouldSaveButtonBeDisabled)
            ) // navigationBarItems

        }
    }
}

struct NewCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayAppPay.Product(name: "no name", price: 100))
    }
}
