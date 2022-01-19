//
//  CardDetailView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct CardDetailView: View {
    @EnvironmentObject private var session: WayPayApp.Session
    @ObservedObject private var keyboardObserver = UI.KeyboardObserver()
    @State var authenticationViewModel = WayPay.AuthenticationViewModel()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false
    @State private var action: Int? = 10
    @State private var validUntil: Date = Calendar.current.date(byAdding: DateComponents(month: 3), to: Date()) ?? Date()
    @State private var consent: AfterBanks.Consent?
    @State var newAlias: String = ""
    @State var newPrice: String = ""

    var card: WayPay.Card?
    
    
    var shouldSaveButtonBeDisabled: Bool {
        if card == nil {
            // creation
            return newAlias.isEmpty || newPrice.isEmpty
        } else {
            // update
            return newAlias.isEmpty && newPrice.isEmpty
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

    var body: some View {
        VStack(alignment: .leading, spacing: UI.Constant.verticalSeparation) {
            VStack(alignment: .trailing, spacing: UI.Constant.verticalSeparation) {
                HStack(alignment: .center, spacing: 12) {
                    Text("Alias")
                    TextField("\(card?.alias ?? WayPay.Card.defaultName)", text: $newAlias)
                        .textContentType(.none)
                        .keyboardType(.default)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(alignment: .center, spacing: 12) {
                    Text("Price")
                    TextField("", text: $newPrice)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button(action: {
                    getConsent()
                    
                }) {
                    Text("Test get consent")
                }
                
                Picker(selection: $action, label: Text("What is your favorite color?")) {
                    Text("Grant").tag(0)
                    Text("Renew").tag(1)
                    Text("Cancel").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
                
            } // VStack
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .onAppear(perform: {
                Logger.message("********************** CardDetailView onAppear: WayAppPay.session.afterBanks.banks count=\(WayPayApp.session.banks.count)")
            })
            Spacer()
        }
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
        .font(.headline)
        .padding()
        .navigationBarTitle(
            newAlias.isEmpty ? (card?.alias ?? "") : newAlias
        )
        .navigationBarItems(trailing:
            Button(action: {
                DispatchQueue.main.async {
                    self.isAPICallOngoing = true
                }
                if self.card == nil {
                    Logger.message("********************** CARD IS NIL")
                } else {
                    // update
                    self.card?.edit(iban: "123456") { error in
                        if error != nil {
                            Logger.message("********************** \(error!.localizedDescription)")
                        } else {
                            Logger.message("********************** CARD EDITED SUCCESSFULLY")
                        }
                    }
                }
            }, label: { Text("Save") })
            .alert(isPresented: $showUpdateResultAlert) {
                Alert(title: Text("System error"),
                      message: Text("Card could not be updated. Try again later. If problem persists contact support@wayapp.com"),
                      dismissButton: .default(Text("OK")))
            }
        .disabled(shouldSaveButtonBeDisabled)
        )
    }
    
    private func getConsent() {
        guard let card = card,
              let accountUUID = session.accountUUID else {
            Logger.message("Missing Card or accountUUID")
            return
        }
        let validUntil: Date = Calendar.current.date(byAdding: DateComponents(month: 3), to: Date()) ?? Date()
        AfterBanks.getConsent(accountUUID: accountUUID,
                              //  service: self.session.afterBanks.banks[self.selectedBank].service,
                              service: "bbva",
                              validUntil: AfterBanks.dateFormatter.string(from: validUntil), pan: card.pan) { error, consent in
            if let error = error {
                Logger.message("********************** CARD CONSENT ERROR=\(error.localizedDescription)")
            } else if let consent = consent {
                Logger.message("********************** CARD CONSENT SUCCESS")
                DispatchQueue.main.async {
                    self.authenticationViewModel.signIn(consent: consent) { error, consent in
                        if let error = error {
                            // Alert user
                            Logger.message(error.localizedDescription)
                        } else if let consent = consent {
                            self.consent = consent
                            Logger.message("SHOW IBANS .....FOR CONSENT=\(consent)")
                        }
                    }
                }
            }
        }
    }
}

struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CardDetailView()
    }
}
