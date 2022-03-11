//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct AccountsView: View {
    @State private var accounts = Container<WayPay.Account>()

    var body: some View {
        List {
            ForEach(accounts) { account in
                NavigationLink(destination: AccountAdminView(account: account)) {
                    Text(account.email ?? "no name")
                }
            }
            .onDelete(perform: delete)
        }
        .navigationBarTitle(Text("Accounts"), displayMode: .inline)
        .navigationBarItems(trailing:
                                NavigationLink(destination: NewCardView()) {
            Image(systemName: "plus.circle")
                .imageScale(.large)})
        .onAppear(perform: {
            load()
        })
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("AccountsView_Previews")
    }
}

extension AccountsView {
    private func load() {
        if accounts.isEmpty {
            WayPay.Account.load { accounts, error in
                Logger.message("Accounts=\(accounts?.count ?? 0)")
                DispatchQueue.main.async {
                    if let accounts = accounts {
                        self.accounts.setTo(accounts)
                    } else {
                        Logger.message("No accounts found")
                    }
                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            WayPay.Account.delete(accounts[offset].accountUUID) { error in
                if let error = error {
                    Logger.message(error.localizedDescription)
                } else {
                    accounts.remove(at: offset)
                }
            }
        }
    }

    
}
