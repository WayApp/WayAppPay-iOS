//
//  CardAdminView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

struct CardAdminView: View {
    var body: some View {
        Form {
            NavigationLink(destination: CardsView()) {
                Label(NSLocalizedString("Cards", comment: "CardAdminView: Cards option"), systemImage: "questionmark.video")
            }

            Button {
                DispatchQueue.main.async {
                    self.expire()
                }
            } label: {
                Label("Expire", systemImage: "calendar.badge.exclamationmark")
            }
            Button {
                DispatchQueue.main.async {
                    self.getCheckin()
                }
            } label: {
                Label("Alcázar checkin", systemImage: "arrow.up.and.person.rectangle.portrait")
            }

        }.navigationBarTitle(Text("Card"), displayMode: .inline)
    }
}

struct CardAdminView_Previews: PreviewProvider {
    static var previews: some View {
        CardAdminView()
    }
}

extension CardAdminView {
    
    private func expire() {
        let issuerUUIDLasRozas = ""
//        let issuerUUIDLasRozas = "f157c0c5-49b4-445a-ad06-70727030b38a"
        //        let issuerUUIDAsCancelas = "65345945-0e04-47b2-ae08-c5e7022a71aa"
        //        let issuerUUIDParquesur = "12412d65-411b-4629-a9ce-b5fb281b11bd"
        WayPay.Issuer.expireCards(issuerUUID: issuerUUIDLasRozas) { issuers, error in
            if let _ = issuers {
                Logger.message("Issuer name: ")
            } else if let error = error  {
                Logger.message("%%%%%%%%%%%%%% Expire ERROR: \(error.localizedDescription)")
            } else {
                Logger.message("%%%%%%%%%%%%%% Expire ERROR: -------------")
            }
        }
    }
    
    private func getCheckin() {
        WayPay.Account.getCheckin(acccountUUID: "d7531225-a57f-4767-b0c8-70303b69cef9", issuerUUID: "7373d487-239e-4966-8988-8d2c81b83251") { checkins, error in
            if let checkins = checkins,
               let checkin = checkins.first {
                Logger.message("Checkin: \(checkin)")
            } else {
                Logger.message("Checkin error. More info: \(error != nil ? error!.localizedDescription : "not available")")
            }
        }
        
    }

}
