//
//  DefaultKeysPersistance.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//

import Foundation

protocol DefaultKeyPersistence: Codable {
    var defaultKey: String { get }
}

extension DefaultKeyPersistence {
    func save() {
        do {
            let data = try WayPay.jsonEncoder.encode(self)
            UserDefaults.standard.set(data, forKey: defaultKey.uppercased())
            UserDefaults.standard.synchronize()
        } catch {
            WayAppUtils.Log.message("Error: \(error.localizedDescription)")
        }
    }
    
    static func load<T: Decodable>(defaultKey: String, type: T.Type) -> T? {
        if let data = UserDefaults.standard.data(forKey: defaultKey.uppercased()) {
            do {
                return try WayPay.jsonDecoder.decode(T.self, from: data)
            } catch {
                WayAppUtils.Log.message("Error: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
