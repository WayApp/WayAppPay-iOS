//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct AccountsView: View {
    @State private var callingAPI = false
    @State private var accounts = Container<WayPay.Account>()
    @State private var selectedAccountFormat: WayPay.Account.Format = .MERCHANT
    @State private var searchText = ""
    
    private var searchResults: [WayPay.Account] {
        if searchText.isEmpty {
            return accounts.filter( { matchesSelectedAccountFormat($0) })
        } else {
            return accounts.filter {
                if let email = $0.email {
                    return email.localizedCaseInsensitiveContains(searchText) && matchesSelectedAccountFormat($0)
                }
                return matchesSelectedAccountFormat($0)
            }
        }
    }
    
    private func matchesSelectedAccountFormat(_ account: WayPay.Account) -> Bool {
        return (account.format == nil && selectedAccountFormat == .MERCHANT) || account.format == selectedAccountFormat
    }
    
    var body: some View {
        ZStack {
            List {
                Picker(selection: $selectedAccountFormat, label: Text("Account format")) {
                    ForEach(WayPay.Account.Format.allCases, id: \.self) { format in
                        Text(format.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Text("Number of accounts: \(searchResults.count)")
                    .font(Font.footnote)
                ForEach(searchResults, id:\.self) { account in
                    NavigationLink(destination: AccountAdminView(account: account)) {
                        Label(account.email ?? "no email", systemImage: account.format?.icon ?? WayPay.Account.Format.MERCHANT.icon)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(account)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .searchable(text: $searchText).autocapitalization(.none)
            .navigationBarTitle(Text("Accounts"), displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: NewAccountView()) {
                Image(systemName: "plus.circle")})
            .onAppear(perform: {
                load()
            })
            if callingAPI {
                ProgressView(WayPay.SingleMessage.progressView.text)
                    .progressViewStyle(UI.WayPayProgressViewStyle())
            }

        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("AccountsView_Previews")
    }
}

extension AccountsView {
    private func load() {
        callingAPI = true
        WayPay.Account.load { accounts, error in
            DispatchQueue.main.async {
                self.callingAPI = false
                if let accounts = accounts {
                    self.accounts.setTo(accounts)
                } else {
                    Logger.message("No accounts found")
                }
            }
        }
    }
    
    private func delete(_ account: WayPay.Account) {
        Logger.message("Email: \(account.email ?? "NO EMAIL"), accountUUID: \(account.accountUUID)")
        WayPay.Account.delete(account.accountUUID) { error in
            if let error = error {
                Logger.message(error.localizedDescription)
            } else {
                accounts.remove(account)
            }
        }
    }
    
}
