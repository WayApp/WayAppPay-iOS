//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct NewCardView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    @ObservedObject private var keyboardObserver = WayAppPay.KeyboardObserver()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false
    @State private var action: Int? = 10
    @State private var selectedCardType = 0
    @State private var consent: AfterBanks.Consent?
    @State var authenticationViewModel = WayAppPay.AuthenticationViewModel()

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
    @State var selectedIssuer: Int = 0
    @State var selectedBank: Int = 0
    @State private var selectedIBAN = 0

    var shouldSaveButtonBeDisabled: Bool {
        if session.accountUUID == nil {
            return true
        }
        switch WayAppPay.Card.PaymentFormat.allCases[selectedCardType] {
        case .PREPAID: return alias.isEmpty
        case .POSTPAID: return alias.isEmpty || consent == nil
        case .CREDIT: return true
        }
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
        return Section(header: Text("Bank account")) {
            DatePicker(selection: $validUntil, displayedComponents: .date) {
                Text("Consent valid until")
            }
            if !session.banks.isEmpty {
                Picker(selection: $selectedBank, label: Text("Bank")) {
                    ForEach(0..<session.banks.count) {
                        Text(self.session.banks[$0].fullname ?? self.session.banks[$0].service)
                    }
                }
            }
            if consent != nil {
                Picker(selection: $selectedIBAN, label: Text("IBAN")) {
                    ForEach(0..<consent!.globalPosition.count) {
                        Text((self.consent!.globalPosition[$0].description ?? "missing description") + "\n" + (self.consent!.globalPosition[$0].iban ?? "missing IBAN"))
                    }
                }            }
            Button(action: {
                self.grantConsent(accountUUID: self.session.accountUUID!)
            }, label: {
                Text("Grant consent")
                    .foregroundColor(.black)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, minHeight: WayAppPay.UI.buttonHeight)
            })
            .disabled(session.banks.isEmpty || (session.accountUUID == nil))
            .background((session.banks.isEmpty || (session.accountUUID == nil)) ? Color.gray : Color.green)
            .cornerRadius(15)
            .animation(.easeInOut(duration: 0.3))
        } // Section
    } // func
    
    private func prepaidOptions() -> some View {
        return Picker(selection: $selectedCurrency, label: Text("Currency")) {
            ForEach(0..<currencies.count, id: \.self) {
                Text(self.currencies[$0])
            }
        }
    }
    
    private func grantConsent(accountUUID: String) {
        AfterBanks.getConsent(accountUUID: accountUUID,
            //  service: self.session.afterBanks.banks[self.selectedBank].service,
            service: "sandbox",
            validUntil: self.dateFormatter.string(from: self.validUntil)) { error, consent in
                if let error = error {
                    WayAppUtils.Log.message("********************** CARD CONSENT ERROR=\(error.localizedDescription)")
                } else if let consent = consent {
                    WayAppUtils.Log.message("********************** CARD CONSENT SUCCESS")
                    DispatchQueue.main.async {
                        self.authenticationViewModel.signIn(consent: consent) { error, consent in
                            if let error = error {
                                // Alert user
                                WayAppUtils.Log.message(error.localizedDescription)
                            } else if let consent = consent {
                                self.consent = consent
                                WayAppUtils.Log.message("SHOW IBANS .....FOR CONSENT=\(consent)")
                            }
                        }
                    }
                }
        }
    }
    
    private func createCard(accountUUID: String) {
        DispatchQueue.main.async {
            self.isAPICallOngoing = true
        }
        WayAppPay.Card.create(alias: self.alias, type: WayAppPay.Card.PaymentFormat.allCases[selectedCardType], consent: consent, selectedIBAN: selectedIBAN) { error, card in
            DispatchQueue.main.async {
                self.isAPICallOngoing = false
            }
            if error != nil {
                DispatchQueue.main.async {
                    self.showUpdateResultAlert = true
                    WayAppUtils.Log.message("********************** \(error!.localizedDescription)")
                }
            }
        }
    }
        
    var body: some View {
        NavigationView {
            ZStack {
                Color.offWhite
                Form {
                    Section(header: Text("")) {
                        HStack(spacing: 15) {
                            Text("Alias")
                            TextField("alias", text: $alias)
                                .textContentType(.nickname)
                                .keyboardType(.default)
                        }
                        .modifier(WayAppPay.TextFieldModifier())
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
                    if isAPICallOngoing {
                        WayAppPay.ActivityIndicator(isAnimating: true)
                    }
                    if WayAppPay.Card.PaymentFormat.allCases[selectedCardType] == .PREPAID {
                        Section(header: Text("Prepaid")) {
                            prepaidOptions()
                        }
                    }
                    if WayAppPay.Card.PaymentFormat.allCases[selectedCardType] == .POSTPAID {
                        postpaidOptions()
                    }
                }
                .background(Color.offWhite)
                .navigationBarTitle(Text("New card"), displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            self.createCard(accountUUID: self.session.accountUUID!)
                                        }, label: { Text("Save") })
                                        .alert(isPresented: $showUpdateResultAlert) {
                                            Alert(title: Text("System error"),
                                                  message: Text("Card could not be created. Try again later. If problem persists contact support@wayapp.com"),
                                                  dismissButton: .default(Text("OK")))
                                        }
                                        .disabled(shouldSaveButtonBeDisabled)
                ) // navigationBarItems
            } // Form
        }
        .gesture(DragGesture().onChanged { _ in WayAppPay.hideKeyboard() })
    }
}

struct NewCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayAppPay.Product(name: "no name", price: 100))
    }
}
