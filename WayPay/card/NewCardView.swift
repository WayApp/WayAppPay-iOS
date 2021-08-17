//
//  ProductDetailView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI

struct NewCardView: View {
    @EnvironmentObject private var session: WayPay.Session
    @ObservedObject private var keyboardObserver = WayPay.KeyboardObserver()
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @State private var isAPICallOngoing = false
    @State private var showUpdateResultAlert = false
    @State private var action: Int? = 10
    @State private var selectedCardType = 0
    @State private var consent: AfterBanks.Consent?
    @State var authenticationViewModel = WayPay.AuthenticationViewModel()

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
        switch WayPay.Card.PaymentFormat.allCases[selectedCardType] {
        case .PREPAID: return alias.isEmpty
        case .POSTPAID: return alias.isEmpty
        default: return true
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
                        Text((self.consent!.globalPosition[$0].iban ?? "missing IBAN"))
                    }
                }            }
            Button(action: {
                self.grantConsent(accountUUID: self.session.accountUUID!)
            }, label: {
                Text("Grant consent")
                    .foregroundColor(.black)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, minHeight: WayPay.UI.buttonHeight)
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
                        Picker(selection: $selectedIssuer, label: Text("Issuer")) {
                            ForEach(0..<session.issuers.count, id: \.self) {
                                Text(self.session.issuers[$0].name ?? "no name")
                            }
                        }
                        Picker(selection: $selectedCardType, label: Text("Type")) {
                            ForEach(0..<WayPay.Card.PaymentFormat.allCases.count, id: \.self) {
                                Text(WayPay.Card.PaymentFormat.allCases[$0].rawValue)
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    if isAPICallOngoing {
                        WayPay.ActivityIndicator(isAnimating: true)
                    }
                    if WayPay.Card.PaymentFormat.allCases[selectedCardType] == .PREPAID {
                        Section(header: Text("Prepaid")) {
                            prepaidOptions()
                        }
                    }
                    if WayPay.Card.PaymentFormat.allCases[selectedCardType] == .POSTPAID {
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
        .gesture(DragGesture().onChanged { _ in hideKeyboard() })
    }
}

struct NewCardView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(product: WayPay.Product(merchantUUID: "",  name: "no name", price: 100))
    }
}
