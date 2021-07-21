//
//  PaymentTransaction.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
    struct PaymentTransaction: Codable, ContainerProtocol, Identifiable {
        
        static let defaultCurrency = Currency.EUR
        
        enum TransactionType: String, Codable {
            static let defaultTitle = NSLocalizedString("Unspecified", comment: "Default PaymentTransaction.TransactionType")
            
            case SALE
            case REFUND
            case ADD
            case TOPUP
            case REWARD
            case CHECKIN
            
            var title: String {
                switch self {
                case .SALE: return NSLocalizedString("Sale", comment: "PaymentTransaction.TransactionType")
                case .REFUND: return NSLocalizedString("Refund", comment: "PaymentTransaction.TransactionType")
                case .ADD: return NSLocalizedString("Add", comment: "PaymentTransaction.TransactionType")
                case .TOPUP: return NSLocalizedString("Top-up", comment: "PaymentTransaction.TransactionType")
                case .REWARD: return NSLocalizedString("Reward", comment: "PaymentTransaction.TransactionType")
                case .CHECKIN: return NSLocalizedString("Checkin", comment: "PaymentTransaction.TransactionType")
                }
            }
        }

        enum TransactionResult: String, Codable {
            case DENIED, ACCEPTED, PROCESSING
            
            var image: some View {
                switch self {
                case .DENIED:
                    return Image(systemName: "x.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.red)
                case .ACCEPTED:
                    return Image(systemName: "checkmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.green)
                case .PROCESSING:
                    return Image(systemName: "questionmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.yellow)
                }
            }
        }
        
        enum ReadingType: String, Codable {
            case STANDARD, BACKUP, TPV_SANTANDER, TPV_PAY, PAYPAL, STRIPE, STRIPE_CARDS, STRIPE_SEPA
        }

        enum PaymentMethod: String, Codable {
            case WALLET, CARD_PINPAD, CASH, TICKET, OTHER, PAYPAL, STRIPE
        }

        var transactionUUID: String?
        var merchantUUID: String?
        var accountUUID: String?
        var pan: String?
        var authorizationCode: String?
        var type: TransactionType?
        var result: TransactionResult?
        var purchaseDetail: [CartItem]?
        var prizes: [Prize]?
        var readingType: ReadingType?
        var paymentMethod: PaymentMethod?
        var amount: Int?
        var currency: Currency?
        var origin: String?
        var receiptImage: String?
        var refund: Bool?
        var creationDate: Date?
        var lastUpdateDate: Date?
        var paymentId: String?
        var follow: String?

        var id: String {
            return transactionUUID ?? UUID().uuidString
        }
        
        var isRefund: Bool {
            return refund ?? false
        }
                
        // Payment with Wallet card
        init(amount: Int, purchaseDetail: [CartItem]? = nil, prizes: [Prize]? = nil, token: String = String(), type: TransactionType = .SALE) {
            self.accountUUID = session.accountUUID
            self.merchantUUID = session.merchantUUID
            self.amount = amount
            self.authorizationCode = token
            self.paymentMethod = .WALLET
            self.type = type
            self.currency = session.merchants.isEmpty ?  PaymentTransaction.defaultCurrency : session.merchants[session.seletectedMerchant].currency
            self.readingType = .STANDARD
            self.accountUUID = session.accountUUID
            self.purchaseDetail = purchaseDetail
            self.prizes = prizes
        }
        
        var isPOSTPAID: Bool {
            return paymentId != nil && follow != nil
        }
        
        func walletPayment() {
            guard let merchantUUID = self.merchantUUID,
                let accountUUID = self.accountUUID else {
                WayAppUtils.Log.message("missing transaction.merchantUUID or transaction.accountUUID")
                return
            }
            WayPay.API.walletPayment(merchantUUID, accountUUID, self).fetch(type: [WayPay.PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        DispatchQueue.main.async {
                            session.transactions.addAsFirst(transaction)
                        }
                        WayAppUtils.Log.message("PAGO HECHO!!!!=\(transaction)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    WayAppUtils.Log.message(error.localizedDescription)
                }
            }
        }

        func processRefund() -> Void {
            guard let merchantUUID = self.merchantUUID,
                let accountUUID = self.accountUUID,
                let transactionUUID = self.transactionUUID else {
                WayAppUtils.Log.message("missing transaction.merchantUUID or transaction.accountUUID")
                return
            }
            WayPay.API.refundTransaction(merchantUUID, accountUUID, transactionUUID, self).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        DispatchQueue.main.async {
                            WayPay.session.transactions.addAsFirst(transaction)
                            WayPay.session.refundState = .success
                        }
                        WayAppUtils.Log.message("REFUND HECHO!!!!=\(transaction)")
                    } else {
                        DispatchQueue.main.async {
                            WayPay.session.refundState = .failure
                        }
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    DispatchQueue.main.async {
                        WayPay.session.refundState = .failure
                    }
                    WayAppUtils.Log.message(error.localizedDescription)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + WayPay.UI.paymentResultDisplayDuration) {
                    WayPay.session.refundState = .none
                }
            }
        }
    
    }
}
