//
//  PaymentTokenView.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 06/09/2020.
//  Copyright © 2020 WayApp. All rights reserved.
//

import SwiftUI
import PassKit

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

struct CardsView: View {
    @EnvironmentObject private var session: WayAppPay.Session
    
    var body: some View {
        NavigationView {
            List {
                ForEach(session.cards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        CardRowView(card: card)}
                }
            } // List
            .navigationBarTitle("Payment tokens", displayMode: .inline)
            .navigationBarItems(trailing:
                                    NavigationLink(destination: NewCardView()) {   Image(systemName: "plus.circle")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .center)
                                    }
                                    .foregroundColor(Color("WAP-Blue"))
                                    .aspectRatio(contentMode: .fit))
        }
    } // Body
    
    func delete(at offsets: IndexSet) {
        WayAppPay.Card.delete(at: offsets)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
    }
}
