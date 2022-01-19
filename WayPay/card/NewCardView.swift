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
//    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false
    @State private var action: Int? = 10
    @State private var selectedCardType = 0
    @State private var consent: AfterBanks.Consent?
    @State private var validUntil: Date = Calendar.current.date(byAdding: DateComponents(month: 3), to: Date()) ?? Date()
    @State var selectedCurrency: Int = 0
    @State var alias: String = ""
    @State var selectedIssuer: Int = 0
    @State var selectedBank: Int = 0
    @State private var selectedIBAN = 0
    @State private var qrCreated = false

    
    let currencies = ["EUR", "USD", "VEF"]

    var shouldSaveButtonBeDisabled: Bool {
        if session.accountUUID == nil {
            return true
        }
        switch WayPay.Card.PaymentFormat.allCases[selectedCardType] {
        case .PREPAID: return alias.isEmpty
        case .POSTPAID: return alias.isEmpty
        default: return true
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
                        Text(self.session.banks[$0].getFullname())
                    }
                }
            }
            if consent != nil {
                Picker(selection: $selectedIBAN, label: Text("IBAN")) {
                    ForEach(0..<consent!.globalPosition.count) {
                        Text((self.consent!.globalPosition[$0].iban ?? "missing IBAN"))
                    }
                }            }
            Button(action: {
                self.grantConsent(accountUUID: self.session.accountUUID!)
            }, label: {
                Text("Grant consent")
                    .foregroundColor(.black)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, minHeight: UI.Constant.buttonHeight)
            })
            .disabled(session.banks.isEmpty || (session.accountUUID == nil))
            .background((session.banks.isEmpty || (session.accountUUID == nil)) ? Color.gray : Color.green)
            .cornerRadius(15)
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
    }
    
    private func createCard(accountUUID: String) {
        DispatchQueue.main.async {
            self.isAPICallOngoing = true
        }
        WayPay.Card.create(alias: self.alias, issuerUUID: session.issuers[selectedIssuer].issuerUUID, type: WayPay.Card.PaymentFormat.allCases[selectedCardType], consent: consent, selectedIBAN: selectedIBAN) { error, card in
            DispatchQueue.main.async {
                self.isAPICallOngoing = false
            }
            if error != nil {
                DispatchQueue.main.async {
                    self.showUpdateResultAlert = true
                    Logger.message("********************** \(error!.localizedDescription)")
                }
            } else {
                self.qrCreated = true
            }
        }
    }
            
    var body: some View {
        Form {
            Section(header: Text("General")) {
                HStack(spacing: 15) {
                    Text("Alias")
                    TextField("alias", text: $alias)
                        .textContentType(.nickname)
                        .keyboardType(.default)
                }
                Picker(selection: $selectedIssuer, label: Text("Issuer")) {
                    ForEach(0..<session.issuers.count, id: \.self) {
                        Text(self.session.issuers[$0].name ?? "no name")
                    }
                }
                Picker(selection: $selectedCardType, label: Text("Type")) {
                    ForEach(0..<WayPay.Card.PaymentFormat.allCases.count, id: \.self) {
                        Text(WayPay.Card.PaymentFormat.allCases[$0].rawValue)
                    }
                }
            }
            if isAPICallOngoing {
                HStack {
                    Spacer()
                    ProgressView(NSLocalizedString("Creating new QR...", comment: "NewCardView: save"))
                    Spacer()
                }
            }
            if WayPay.Card.PaymentFormat.allCases[selectedCardType] == .PREPAID {
                Section(header: Text("Prepaid")) {
                    prepaidOptions()
                }
            }
            if WayPay.Card.PaymentFormat.allCases[selectedCardType] == .POSTPAID && qrCreated{
                postpaidOptions()
            }
        } // Form
        .onAppear(perform: {
            AfterBanks.getBanks()
            WayPay.Issuer.get()
        })
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
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
    }
}

struct NewCardView_Previews: PreviewProvider {
    static var previews: some View {
        NewCardView()
    }
}
