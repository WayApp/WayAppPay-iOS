//
//  PaymentTransaction.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import SwiftUI

extension WayPay {
    struct CartItem: Codable {
        var name: String?
        var price: Int // defined as Int in API
        var quantity: Int // defined as Int in API
    }

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
            
            var icon: String {
                switch self {
                case .SALE: return "plus.square.fill"
                case .REFUND: return "minus.square.fill"
                case .ADD: return "plus.square.fill"
                case .TOPUP: return "rectangle.fill.badge.plus"
                case .REWARD: return "seal.fill"
                case .CHECKIN: return "person.fill.viewfinder"
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
        var ticketURL: String?

        var id: String {
            return transactionUUID ?? UUID().uuidString
        }
        
        var isRefund: Bool {
            return refund ?? false
        }
                
        // Payment with Wallet card
        init(amount: Int, purchaseDetail: [CartItem]? = nil, prizes: [Prize]? = nil, token: String = String(), type: TransactionType = .SALE) {
            self.accountUUID = WayPayApp.session.accountUUID
            self.merchantUUID = WayPayApp.session.merchantUUID
            self.amount = amount
            self.authorizationCode = token
            self.paymentMethod = .WALLET
            self.type = type
            self.currency = WayPayApp.session.merchant == nil ?  PaymentTransaction.defaultCurrency : WayPayApp.session.merchant!.currency
            self.readingType = .STANDARD
            self.accountUUID = WayPayApp.session.accountUUID
            self.purchaseDetail = purchaseDetail
            self.prizes = prizes
        }
        
        var isPOSTPAID: Bool {
            return paymentId != nil && follow != nil
        }
        
        var wasSuccessful: Bool {
            return result == .ACCEPTED
        }
        
        func walletPayment() {
            guard let merchantUUID = self.merchantUUID,
                let accountUUID = self.accountUUID else {
                Logger.message("missing transaction.merchantUUID or transaction.accountUUID")
                return
            }
            WayPay.API.walletPayment(merchantUUID, accountUUID, self).fetch(type: [WayPay.PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        DispatchQueue.main.async {
                            WayPayApp.session.transactions.addAsFirst(transaction)
                        }
                        Logger.message("PAGO HECHO!!!!=\(transaction)")
                    } else {
                        WayPay.API.reportError(response)
                    }
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                }
            }
        }

        func processRefund(completion: @escaping (PaymentTransaction?, Error?) -> Void) -> Void {
            guard let merchantUUID = self.merchantUUID,
                let accountUUID = self.accountUUID,
                let transactionUUID = self.transactionUUID else {
                Logger.message("missing transaction.merchantUUID or transaction.accountUUID")
                return
            }
            WayPay.API.refundTransaction(merchantUUID, accountUUID, transactionUUID, self).fetch(type: [PaymentTransaction].self) { response in
                if case .success(let response?) = response {
                    if let transactions = response.result,
                        let transaction = transactions.first {
                        DispatchQueue.main.async {
                            WayPayApp.session.transactions.addAsFirst(transaction)
                            completion(transaction, nil)
                        }
                    } else {
                        WayPay.API.reportError(response)
                        completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                    }
                } else if case .failure(let error) = response {
                    Logger.message(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
        
        func getPurchaseDetail() -> String {
            var description = String()
            if let purchaseDetail = purchaseDetail {
                for cartItem in purchaseDetail {
                    if let name = cartItem.name {
                        description.append((description.isEmpty ? "" : ", ") + name + " (\(cartItem.quantity))")
                    }
                }
            }
            
            return description
        }
    
        func saveTicket(ticketImage: UIImage?, completion: @escaping ([PaymentTransaction]?, Error?) -> Void) {
            guard let merchantUUID = merchantUUID,
                    let transactionUUID = transactionUUID else { return }
            
            WayPay.API.saveTicket(merchantUUID, transactionUUID, ticketImage).fetch(type: [PaymentTransaction].self) { response in
                switch response {
                case .success(let response?):
                    completion(response.result, nil)
                case .failure(let error):
                    completion(nil, error)
                default:
                    completion(nil, WayPay.API.ResponseError.INVALID_SERVER_DATA)
                }
            }
        }

    }
}
