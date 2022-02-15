//
//  CardsView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
//

import SwiftUI

import PassKit

struct CardsView: View {
    @EnvironmentObject private var session: WayPayApp.Session
    @State var cards = [WayPay.Card]()
    @State var showActivityIndicator: Bool = true

    var body: some View {
        ZStack {
            List {
                ForEach(cards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        CardRowView(card: card)}
                }
                .onDelete(perform: delete)
            } // List
            .navigationBarTitle("QRs", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: NewCardView()) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)})
            if showActivityIndicator {
                ProgressView(WayPay.SingleMessage.progressView.text)
                    .progressViewStyle(UI.WayPayProgressViewStyle())
            }
        }
        .onAppear(perform: loadCards)
    } // Body
    
    func loadCards() {
        if let accountUUID = session.accountUUID {
            WayPay.Card.getCards(accountUUID: accountUUID) { cards, error in
                self.showActivityIndicator = false
                if cards != nil {
                    Logger.message("Found \(cards!.count) cards")
                    self.cards = cards!
                } else {
                    //TODO: alert user
                }   
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        if let accountUUID = session.accountUUID {
            for offset in offsets {
                WayPay.API.deleteCard(accountUUID, cards[offset].pan).fetch(type: [String].self) { response in
                    if case .success(_) = response {
                        cards.remove(at: offset)
                    } else if case .failure(let error) = response {
                        Logger.message(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
    }
}

struct PassViewer: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var pass: PKPass

    class Coordinator: NSObject, UINavigationControllerDelegate, PKAddPassesViewControllerDelegate {
        var parent: PassViewer

        init(_ parent: PassViewer) {
            self.parent = parent
        }
        
        func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<PassViewer>) -> PKAddPassesViewController {
        if let picker = PKAddPassesViewController(pass: pass) {
            picker.delegate = context.coordinator
            return picker
        } else {
            return PKAddPassesViewController()
        }
    }

    func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: UIViewControllerRepresentableContext<PassViewer>) {
    }
    
}

