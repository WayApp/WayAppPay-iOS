//
//  WayAppUtils.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 1/31/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import UIKit

struct WayAppUtils {
    
    struct Log {
        static let isOn = false
        
        static func message(fileName: String = #file, functionName: String = #function, _ message: String = "") {
            if (isOn) {
                var fileNameLastComponent = URL(fileURLWithPath: fileName)
                fileNameLastComponent = fileNameLastComponent.deletingPathExtension()
                print("\n\n>>\(fileNameLastComponent.lastPathComponent): \(functionName): \(message)")
            }
        }
    }
    
}

extension WayAppUtils {
    /* Embed confidential information in items that you store in a keychain
     * Typical use is:
     * 1) Credentials:
     *    let genericPassword = KeychainHandler.GenericPasswordCredentials(account: "myAccount", password: "myPassword", service: "myService")
     * 2) Create:
     *    let query = KeychainHandler.createGenericPasswordQuery(for: genericPassword)
     * 3) Add or update:
     *    try KeychainHandler.addQuery(query)
     * 4) Search:
     *    try KeychainHandler.searchGenericPasswordQuery(account: "myAccount", service: "myService")
     */
    struct KeychainHandler {
        typealias Query = [String: Any]
        // MARK: - Handled and unhandled errors
        enum Error: Swift.Error {
            case passwordNotFound
            case unexpectedPasswordData
            case duplicateItem
            case unhandled(status: OSStatus)
        }
        // MARK: - Data structures
        struct InternetPasswordCredentials: CustomStringConvertible {
            let account: String
            let password: String
            let server: String
            
            var description : String {
                var description = "***** \(String(describing: Swift.type(of: self))) *****\n"
                let selfMirror = Mirror(reflecting: self)
                for child in selfMirror.children {
                    if let propertyName = child.label {
                        description += "\(propertyName): \(child.value)\n"
                    }
                }
                description += "*****\n"
                return description
            }
        }

        struct GenericPasswordCredentials: CustomStringConvertible {
            let account: String
            let password: String
            let service: String
            
            var description : String {
                var description = "***** \(String(describing: Swift.type(of: self))) *****\n"
                let selfMirror = Mirror(reflecting: self)
                for child in selfMirror.children {
                    if let propertyName = child.label {
                        description += "\(propertyName): \(child.value)\n"
                    }
                }
                description += "*****\n"
                return description
            }
        }
        // MARK: - Generic to all query formats
        static func deleteQuery(_ query: Query) throws {
            let status = SecItemDelete(query as CFDictionary)
            guard status != errSecItemNotFound else { throw KeychainHandler.Error.passwordNotFound }
            guard status == errSecSuccess else { throw Error.unhandled(status: status) }
        }

        static func updateQuery(_ query: Query, password: String) throws {
            let passwordData = password.data(using: String.Encoding.utf8)!
            let attribute: [String: Any] = [kSecValueData as String: passwordData]
            let status = SecItemUpdate(query as CFDictionary, attribute as CFDictionary)
            guard status != errSecItemNotFound else { throw KeychainHandler.Error.passwordNotFound }
            guard status == errSecSuccess else { throw Error.unhandled(status: status) }
        }

        static func addQuery(_ query: Query) throws {
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status != errSecDuplicateItem else { throw KeychainHandler.Error.duplicateItem }
            guard status == errSecSuccess else { throw Error.unhandled(status: status) }
        }
        
        static func createInternetPasswordQuery(for credentials: InternetPasswordCredentials) -> Query {
            let passwordData = credentials.password.data(using: String.Encoding.utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: credentials.account,
                                        kSecAttrServer as String: credentials.server,
                                        kSecValueData as String: passwordData]
            return query
        }
        
        
        /// Searches for server. There may be several accounts, but kSecMatchLimit is set to 1
        ///
        /// - Parameter server: service URL
        /// - Returns: the full KeychainHandlerCredentials. SecItemCopyMatching does not return an Array
        /// - Throws: when the expected KeychainHandlerCredentials for kSecReturnData cannot be parsed
        static func searchInternetPasswordQuery(server: String) throws -> InternetPasswordCredentials {
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrServer as String: server,
                                        kSecReturnAttributes as String: true,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecReturnData as String: true]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status != errSecItemNotFound else { throw KeychainHandler.Error.passwordNotFound }
            guard status == errSecSuccess else { throw KeychainHandler.Error.unhandled(status: status) }
            guard let existingItem = item as? Query,
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8),
                let account = existingItem[kSecAttrAccount as String] as? String
                else {
                    throw Error.unexpectedPasswordData
            }
            return InternetPasswordCredentials(account: account, password: password, server: server)
        }
        
        /// Searches for account and server
        /// Uses kSecReturnAttributes = false, so SecItemCopyMatching does not return a Dictionary
        ///
        /// - Parameters:
        ///   - account: user account
        ///   - server: service URL
        /// - Returns: only kSecReturnData as a String
        /// - Throws: when the expected String for kSecReturnData cannot be parsed
        static func searchInternetPasswordQuery(account: String, server: String) throws -> String {
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrServer as String: server,
                                        kSecAttrAccount as String: account,
                                        kSecReturnAttributes as String: false,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecReturnData as String: true]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status != errSecItemNotFound else { throw Error.passwordNotFound }
            guard status == errSecSuccess else { throw Error.unhandled(status: status) }
            if let passwordData = item as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8) {
                return password
            } else {
                throw Error.unexpectedPasswordData
            }
        }

        static func createGenericPasswordQuery(for credentials: GenericPasswordCredentials) -> Query {
            let passwordData = credentials.password.data(using: String.Encoding.utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrAccount as String: credentials.account,
                                        kSecAttrService as String: credentials.service,
                                        kSecValueData as String: passwordData]
            return query
        }
        
        /// Searches for service. There may be several accounts, but kSecMatchLimit is set to 1
        ///
        /// - Parameter service: service URL
        /// - Returns: the full KeychainHandlerCredentials. SecItemCopyMatching does not return an Array
        /// - Throws: when the expected KeychainHandlerCredentials for kSecReturnData cannot be parsed
        static func searchGenericPasswordQuery(service: String) throws -> GenericPasswordCredentials {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service,
                                        kSecReturnAttributes as String: true,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecReturnData as String: true]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status != errSecItemNotFound else { throw Error.passwordNotFound }
            guard status == errSecSuccess else { throw Error.unhandled(status: status) }
            guard let existingItem = item as? Query,
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8),
                let account = existingItem[kSecAttrAccount as String] as? String
                else {
                    throw Error.unexpectedPasswordData
            }
            return GenericPasswordCredentials(account: account, password: password, service: service)
        }
        
        /// Searches for account and service
        /// Uses kSecReturnAttributes = false, so SecItemCopyMatching does not return a Dictionary
        ///
        /// - Parameters:
        ///   - account: user account
        ///   - service: service URL
        /// - Returns: only kSecReturnData as a String
        /// - Throws: when the expected String for kSecReturnData cannot be parsed
        static func searchGenericPasswordQuery(account: String, service: String) throws -> String {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service,
                                        kSecAttrAccount as String: account,
                                        kSecReturnAttributes as String: false,
                                        kSecMatchLimit as String: kSecMatchLimitOne,
                                        kSecReturnData as String: true]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status != errSecItemNotFound else { throw Error.passwordNotFound }
            guard status == errSecSuccess else { throw Error.unhandled(status: status) }
            if let passwordData = item as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8) {
                return password
            } else {
                throw Error.unexpectedPasswordData
            }
        }
    }
}

extension WayAppUtils {
    struct CachedImages {
        /*
         * In this first stage all images will have the same cost
         * There is no use of countLimit and totalCostLimit
         */
        static var images = NSCache<NSString, UIImage>()
        static func add(image: UIImage, forURL url: String) {
            images.setObject(image, forKey: url as NSString, cost: 1)
        }
        static func get(url: String) -> UIImage? {
            return images.object(forKey: url as NSString)
        }
        static func empty() {
            images.removeAllObjects()
        }
    }

    struct ImageDownloader {
        private var sessionTask: URLSessionDataTask?
        
        mutating func get(imageURL: String?, orDefault defaultImage: UIImage, addToCache: Bool = false, result: @escaping (UIImage) -> Void) {
            get(imageURL: imageURL, addToCache: addToCache) { image in
                if let image = image {
                    result(image)
                } else {
                    result(defaultImage)
                }
            }
        }
        
        mutating func get(imageURL: String?, addToCache: Bool = false, result: @escaping (UIImage?) -> Void) {
            guard let imageURL = imageURL else {
                result(nil)
                return
            }
            if let image = CachedImages.get(url: imageURL) {
                result(image)
            } else if let url = URL(string: imageURL) {
                sessionTask = URLSession.shared.dataTask(with: URLRequest(url:url), completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    if let data = data,
                        let scaledImage = UIImage(data: data, scale: 1.5) {
                        if addToCache {
                            CachedImages.add(image: scaledImage, forURL: imageURL)
                        }
                        result(scaledImage)
                    } else {
                        result(nil)
                    }
                })
                sessionTask?.resume()
            } else {
                result(nil)
            }
        }
        
        func cancel() {
            sessionTask?.cancel()
        }
    }
}

// MARK: Login
extension WayAppUtils {
    static func validateEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }

        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let count = email.count

        if let formatter = try? NSRegularExpression(pattern: pattern, options: []),
            let match = formatter.firstMatch(in: email, options: [], range: NSMakeRange(0, count)),
            match.range.length == count {
            return true
        }
        return false
    }
    
}
