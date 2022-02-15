//
//  NewCardView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct NewCardView: View {
    @EnvironmentObject private var session: WayPayApp.Session
    @ObservedObject private var keyboardObserver = UI.KeyboardObserver()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var callingAPI = false
    @State private var showCreateErrorAlert = false
    @State private var selectedCardType = -1
    @State private var consent: AfterBanks.Consent?
    @State private var validUntil: Date = Calendar.current.date(byAdding: DateComponents(month: 3), to: Date()) ?? Date()
    @State var selectedCurrency: Int = 0
    @State var alias: String = ""
    @State var selectedIssuer: Int = 0
    @State var selectedBank: Int = -1
    @State private var selectedIBAN = -1
    @State private var consentGranted: Bool = false
    
    @State private var banks = [AfterBanks.SupportedBank]()
    @State private var issuers = [WayPay.Issuer]()
    @State private var card: WayPay.Card? = nil
    @State private var authenticationViewModel = WayPay.AuthenticationViewModel()

    let currencies = ["EUR", "USD", "VEF"]
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("General")) {
                    commonOptions
                }
                if showPrepaidOptions {
                    Section(header: Text("Prepaid")) {
                        prepaidOptions
                    }
                }
                if showConsentOptions {
                    Section(header: Text("Bank account")) {
                        postpaidOptions
                    }
                }
            } // Form
            if callingAPI {
                ProgressView(WayPay.SingleMessage.progressView.text)
                    .progressViewStyle(UI.WayPayProgressViewStyle())
            }
        }
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
        .navigationBarTitle(Text("New QR"), displayMode: .inline)
        .navigationBarItems(trailing:
                                saveButton
                                .alert(isPresented: $showCreateErrorAlert) { alertCreationError })
        .onAppear(perform: {
            loadIssuers()
            loadBanks()
        })
    }

    private func loadIssuers() {
        WayPay.Issuer.get() { issuers, error in
            if issuers != nil {
                self.issuers = issuers!
            } else {
                //TODO: alert user
            }
        }
    }
    
    private func loadBanks() {
        AfterBanks.getBanks() { banks, error in
            if banks != nil {
                self.banks = banks!
            } else {
                //TODO: alert user
            }
        }
    }

    private var disableSaveButton: Bool {
        if callingAPI || card != nil || selectedCardType == -1 {
            return true
        }
        switch WayPay.Card.PaymentFormat.allCases[selectedCardType] {
        case .PREPAID: return alias.isEmpty
        case .POSTPAID: return alias.isEmpty
        default: return true
        }
    }
    
    private var disableConsentButton: Bool {
        if callingAPI {
            return true
        }
        return selectedBank == -1
    }

    private var commonOptions: some View {
        Group {
            HStack(spacing: 15) {
                Text("Alias")
                TextField("alias", text: $alias)
                    .textContentType(.nickname)
                    .keyboardType(.default)
            }
            Picker(selection: $selectedIssuer, label: Text("Issuer")) {
                ForEach(0..<issuers.count, id: \.self) {
                    Text(issuers[$0].name ?? "no name")
                }
            }
            Picker(selection: $selectedCardType, label: Text("Type")) {
                ForEach(0..<WayPay.Card.PaymentFormat.allCases.count, id: \.self) {
                    Text(WayPay.Card.PaymentFormat.allCases[$0].rawValue)
                }
            }
        }
    }

    private var prepaidOptions: some View {
        Picker(selection: $selectedCurrency, label: Text("Currency")) {
            ForEach(0..<currencies.count, id: \.self) {
                Text(self.currencies[$0])
            }
        }
    }
    
    private var disableFinishButton: Bool {
        return selectedIBAN == -1
    }

    private var postpaidOptions: some View {
        Group {
            DatePicker(selection: $validUntil, displayedComponents: .date) {
                Text("Consent valid until")
            }
            if !banks.isEmpty {
                Picker(selection: $selectedBank, label: Text("Bank")) {
                    ForEach(0..<banks.count) {
                        Text(banks[$0].getFullname())
                    }
                }
            }
            if consent != nil {
                Picker(selection: $selectedIBAN, label: Text("IBAN")) {
                    ForEach(0..<consent!.globalPosition.count) {
                        Text((self.consent!.globalPosition[$0].iban ?? "missing IBAN"))
                    }
                }
            }
            if (!consentGranted) {
                Button(action: grantConsent , label: { Text("Grant consent").padding() })
                    .disabled(disableConsentButton)
                    .buttonStyle(UI.WideButtonModifier())
            }
            if (consentGranted) {
                Button(action: addIBAN , label: { Text("Finish").padding() })
                    .disabled(disableFinishButton)
                    .buttonStyle(UI.WideButtonModifier())
            }
        } // Group
    }
        
    private func addIBAN() {
        self.callingAPI = true
        if let consent = consent,
            let iban = consent.globalPosition[selectedIBAN].iban {
            card?.addIBAN(iban: iban) { card, error in
                self.callingAPI = false
                if error != nil {
                    self.showCreateErrorAlert = true
                } else {
                    dismissView()
                }
            }
        }
    }
    
    private func grantConsent() {
        if let card = card {
            self.callingAPI = true
            AfterBanks.getConsent(service: banks[selectedBank].service, validUntil: validUntil, pan: card.pan) { consent, error in
                self.callingAPI = false
                if error != nil {
                    self.showCreateErrorAlert = true
                } else if let consent = consent {
                    DispatchQueue.main.async {
                        self.authenticationViewModel.signIn(consent: consent) { error, consent in
                            if let error = error {
                                // Alert user
                                Logger.message(error.localizedDescription)
                            } else if let consent = consent {
                                self.card?.consentId = consent.consentId
                                self.card?.service = banks[selectedBank].service
                                self.consentGranted = true
                                self.consent = consent
                                Logger.message("SHOW IBANS .....FOR CONSENT=\(consent)")
                            }
                        }
                    }
                }
            }

        }
    }
    
    private func dismissView() {
        DispatchQueue.main.async {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var showConsentOptions: Bool {
        if (selectedCardType == -1) {
            return false
        }
        return WayPay.Card.PaymentFormat.allCases[selectedCardType] == .POSTPAID && card != nil
    }
    
    var showPrepaidOptions: Bool {
        if (selectedCardType == -1) {
            return false
        }
        return  WayPay.Card.PaymentFormat.allCases[selectedCardType] == .PREPAID
    }
    
    private func createCard() {
        self.callingAPI = true
        WayPay.Card.create(alias: self.alias, issuerUUID: issuers[selectedIssuer].issuerUUID, type: WayPay.Card.PaymentFormat.allCases[selectedCardType], consent: consent, selectedIBAN: selectedIBAN) { error, card in
            self.callingAPI = false
            if error != nil {
                self.showCreateErrorAlert = true
            } else {
                self.card = card
                if card?.type == .PREPAID {
                    dismissView()
                }
            }
        }
    }
        
    var saveButton: some View {
        Button(NSLocalizedString("Save", comment: "NewCardView: navigationBarItems"), action: createCard)
            .disabled(disableSaveButton)
    }
    
    var alertCreationError: Alert {
        Alert(title: Text("System error"),
              message: Text("Card could not be created. Try again later. If problem persists contact support@wayapp.com"),
              dismissButton: .default(Text("OK")))
    }
}

struct NewCardView_Previews: PreviewProvider {
    static var previews: some View {
        NewCardView()
    }
}
