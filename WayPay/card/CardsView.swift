//
//  CardsView.swift
//  WayPay
//
//  Created by Oscar Anzola on 18/1/22.
//  Copyright © 2022 WayApp. All rights reserved.
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
    @EnvironmentObject private var session: WayPayApp.Session
    
    var body: some View {
        List {
            ForEach(session.cards) { card in
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
    } // Body
    
    func delete(at offsets: IndexSet) {
        WayPay.Card.delete(at: offsets)
    }
}

struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        CardsView()
    }
}
