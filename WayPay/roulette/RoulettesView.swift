//
//  CommunityAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct RoulettesView: View {
    @State private var roulettes = Container<WayPay.Roulette>()
    var customer: WayPay.Customer
    var issuer: WayPay.Issuer

    var body: some View {
            List {
                ForEach(roulettes) { roulette in
                    Text(roulette.rouletteUUID)
                }
                .onDelete(perform: delete)
            }
            .navigationBarTitle(Text("Roulettes"), displayMode: .inline)
            .navigationBarItems(trailing:
                NavigationLink(destination: NewCardView()) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)})
            .onAppear(perform: {
                load()
            })
    }
}

struct RoulettesView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Issuers")
    }
}

extension RoulettesView {
    private func load() {
        if roulettes.isEmpty {
            WayPay.Roulette.load(customerUUID: customer.customerUUID, issuerUUID: issuer.issuerUUID) { roulettes, error in
                DispatchQueue.main.async {
                    if let roulettes = roulettes {
                        self.roulettes.setTo(roulettes)
                    } else {
                        Logger.message("No roulettes found")
                    }
                }
            }
        }
    }
    
    
    private func delete(at offsets: IndexSet) {
        for offset in offsets {
            WayPay.Roulette.detail(customerUUID: customer.customerUUID, issuerUUID: issuer.issuerUUID, rouletteUUID: roulettes[offset].rouletteUUID) { roulettes, error in
                if let roulettes = roulettes,
                   let roulette = roulettes.first {
                    let spin: WayPay.Spin = WayPay.Spin(issuerUUID: issuer.issuerUUID, rouletteUUID: roulette.rouletteUUID, result: 3, token: "Hola")
                    WayPay.Roulette.spin(customerUUID: customer.customerUUID, issuerUUID: issuer.issuerUUID, rouletteUUID: roulette.rouletteUUID, spin: spin) { roulettes, error in
                        if let roulettes = roulettes,
                           let roulette = roulettes.first {
                            Logger.message("ROULETTE UUID: \(roulette.rouletteUUID), result: \(roulette.result ?? -1)")
                        } else {
                            Logger.message("Roulette did not SPIN")
                        }
                    }
                    Logger.message("ROULETTE UUID: \(roulette.rouletteUUID)")
                } else {
                    Logger.message("No roulettes found")
                }
            }
        }
    }
    
    
}
