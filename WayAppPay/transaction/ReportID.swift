//
//  ReportID.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/8/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

extension WayAppPay {
    
    struct ReportID: Codable, Identifiable, ContainerProtocol {
        var idReport: String
        var merchantUUID: String?
        var totalSales: Int?
        var totalRefund: Int?
        var sales: [String: Int]?
        var refund: [String: Int]?
        var totalPerDay: [Int]?
        var refundPerDay: [Int]?
        
        var id: String {
            return idReport
        }
        
        var containerID: String {
            return idReport
        }
        
        static func idReportForMonth(_ date: Date) -> String {
            return String(ISO8601DateFormatter.string(from: Date(), timeZone: TimeZone.current, formatOptions: [.withFullDate]).prefix(7))
        }
    }
}
