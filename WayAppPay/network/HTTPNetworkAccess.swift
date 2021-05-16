//
//  HTTPNetworkAccess.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 12/18/19.
//  Copyright © 2019 WayApp. All rights reserved.
//


import UIKit
import SystemConfiguration

protocol HTTPCallEndpoint {
    var url: URL? { get }
    var body: (String, Data)? { get }
    var headers: [String: String]? { get }
    func isUnauthorizedStatusCode(_ code: Int) -> Bool
    func isSuccessStatusCodeWithJSONResponse(_ code: Int) -> Bool
    func isSuccessStatusCodeWithNoDataResponse(_ code: Int) -> Bool // Allows for methods to be successful but no data
    static var jsonEncoder: JSONEncoder { get }
    static var jsonDecoder: JSONDecoder  { get }
}

extension HTTPCallEndpoint {

    func isSuccessStatusCodeWithNoDataResponse(_ code: Int) -> Bool {
        if code == 202 || code == 204 {
            return true
        }
        return false
    }
    
    func isSuccessStatusCodeWithJSONResponse(_ code: Int) -> Bool {
        return code >= 200 && code < 300
    }
}

enum HTTPCall {
    case DELETE(HTTPCallEndpoint)
    case GET(HTTPCallEndpoint)
    case PATCH(HTTPCallEndpoint)
    case POST(HTTPCallEndpoint)
    case PUT(HTTPCallEndpoint)
    
    private var method: String {
        switch self {
        case .DELETE: return "DELETE"
        case .GET: return "GET"
        case .PATCH: return "PATCH"
        case .POST: return "POST"
        case .PUT: return "PUT"
        }
    }
    
    /// Indicator that the data model should be a Struct with the Enum and Endpoint. But Enum is still better
    private var endpoint: HTTPCallEndpoint {
        switch self {
        case .DELETE(let e): return e
        case .GET(let e): return e
        case .PATCH(let e): return e
        case .POST(let e): return e
        case .PUT(let e): return e
        }
    }
    
    private func buildRequest(_ endPoint: HTTPCallEndpoint) -> URLRequest? {
        guard let url = endPoint.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.method
        addEndPointBody(endPoint: endPoint, to: &urlRequest)
        addEndPointHeaders(endPoint: endPoint, to: &urlRequest)
        return urlRequest
    }
    
    private func addEndPointHeaders(endPoint: HTTPCallEndpoint, to urlRequest: inout URLRequest) {
        if let headers = endPoint.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
    private func addEndPointBody(endPoint: HTTPCallEndpoint, to urlRequest: inout URLRequest) {
        if let contentType = endPoint.body?.0,
            let bodyData = endPoint.body?.1 {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = bodyData
        }
    }
    
    private var urlRequest: URLRequest? {
        switch self {
        case .DELETE(let e): return buildRequest(e)
        case .GET(let e): return buildRequest(e)
        case .PATCH(let e): return buildRequest(e)
        case .POST(let e): return buildRequest(e)
        case .PUT(let e): return buildRequest(e)
        }
    }
    
    enum Error: Swift.Error {
        case http(statusCode: Int, description: String, data: Data?)
        case jsonConversion
        case invalidRequest
        case invalidServerResponse
        case invalidData
        case unhandled(Swift.Error)
        case noNetwork
        
        var localizedDescription: String {
            switch self {
            case .http(_, let description, let data):
                if let data = data,
                    let moreInfo = String(data: data, encoding: String.Encoding.utf8) {
                    return description + "\n" + moreInfo
                }
                return description
            case .jsonConversion: return NSLocalizedString("JSON conversion error", comment: "HTTPCall: Error: jsonConversion")
            case .invalidRequest : return NSLocalizedString("Invalid API request. Check URL", comment: "HTTPCall: Error: invalidRequest")
            case .invalidServerResponse : return NSLocalizedString("Invalid server response", comment: "HTTPCall: Error: invalidServerResponse")
            case .invalidData: return NSLocalizedString("Unexpected server data", comment: "HTTPCall: Error: invalidData")
            case .unhandled(let e): return e.localizedDescription
            case .noNetwork: return NSLocalizedString("No network", comment: "HTTPCall: Error: noNetwork")
            }
        }
        
        static func ==(lhs: Error, rhs: Error) -> Bool {
            switch (lhs, rhs) {
            case (.http, .http): return true
            case (.jsonConversion, .jsonConversion): return true
            case (.invalidRequest, .invalidRequest): return true
            case (.invalidServerResponse, .invalidServerResponse): return true
            case (.invalidData, .invalidData): return true
            case (.unhandled, .unhandled): return true
            case (.noNetwork, .noNetwork): return true
            default:
                return false
            }
        }
    }
    
    func task<T: Decodable>(type decodingType: T.Type, completionHandler result: @escaping (Decodable? ,Error?) -> Void) {
        // Check Internet access
        guard HTTPCall.isNetworkReachable() else {
            result(nil, .noNetwork)
            return
        }
        // Builds URLRequest
        guard let urlRequest = self.urlRequest else {
            result(nil, .invalidRequest)
            return
        }
        WayAppUtils.Log.message("urlRequest url: \(urlRequest.url?.absoluteString ?? "no URL")")
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            // First check needs to be with error (not data), as data can be nil in successful responses
            if let error = error {
                WayAppUtils.Log.message("HTTP_response: \(response.debugDescription)")
                result(nil, .unhandled(error))
            } else if let data = data,
                      let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let objectResponse = try? WayAppPay.jsonDecoder.decode(decodingType, from: data),
                      let code = jsonResponse["code"] as? Int {
                WayAppUtils.Log.message("\nurlRequest: \(urlRequest)\nData: \(objectResponse)")
                
                if self.endpoint.isSuccessStatusCodeWithJSONResponse(code) {
                    result(objectResponse, nil)
                } else {
                    result(nil, .http(statusCode: code, description: HTTPURLResponse.localizedString(forStatusCode: code), data: data))
                }
            } else {
                result(nil, .invalidServerResponse)
            }
        }).resume()
    }
    
    static func isNetworkReachable() -> Bool {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com") else { return false }
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
    
    static func preferredIPAddress(_ interfaces: [(String, String)]) -> String? {
        var wifiIP: String?
        
        for (name, ip) in interfaces {
            if name == "pdp_ip0" {
                return ip
            } else if name == "en0" {
                wifiIP = ip
            }
        }
        return wifiIP
    }
    
    static func getIPAddresses(includeIPV6: Bool = false) -> [(String, String)] {
        var addresses = [(String, String)]()
        
        // Get list of all interfaces on the local machine
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                
                if addr.sa_family == UInt8(AF_INET) || (addr.sa_family == UInt8(AF_INET6) && includeIPV6) {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        let name = String(cString: ptr.pointee.ifa_name)
                        addresses.append((name, address))
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        return addresses
    }
}

// MARK: - MultiPart
extension HTTPCall {
    private static let boundary = "AaBbCc010203" // Arbitrary string not to ever be present in the POST payload
    
    enum BodyPart {
        case JSON(name: String, json: String)
        case image(name: String, image: UIImage)
        case data(name: String, data: Data)
        case multipart([BodyPart])
        case object(name: String, contentType: String, data: Data)
        
        var data: Data {
            switch self {
            case .JSON(_, let json): return json.data(using: .utf8) ?? Data()
            case .image(_, let image): return image.jpegData(compressionQuality: 0.1) ?? Data()
            case .data(_, let data): return data
            case .multipart(let parts): return setMultipartBody(parts)
            case .object(_, _, let data): return data
            }
        }
        var contentType: String {
            switch self {
            case .JSON, .data: return "application/json"
            case .image: return "image/jpeg"
            case .multipart: return "multipart/form-data; boundary=\(HTTPCall.boundary)"
            case .object(_, let contentType, _): return contentType
            }
        }
        var name: String {
            switch self {
            case .JSON(let name, _), .image(let name, _), .data(let name, _): return name
            case .multipart: return "multipart"
            case .object(let name, _, _): return name
            }
        }
        // Better done as init and not as part of the enum definition so that it can fail graciously. Otherwise forces Data to be Optional
        init?<T: Encodable>(_ object: T, name: String, contentType: String = "application/json") {
            if let data = try? WayAppPay.jsonEncoder.encode(object) {
                self = .object(name: name, contentType: contentType, data: data)
            } else {
                return nil
            }
        }
    }

    private static func setMultipartBody(_ multiparts: [BodyPart?]) -> Data {
        var body = Data()
        for case let element? in multiparts {
            body.append("--\(HTTPCall.boundary)\r\n".data(using: .utf8)!)
            // Needs carriage return and new line
            body.append("Content-Disposition: form-data; name=\"\(element.name)\"\r\n".data(using: .utf8)!)
            // Needs double carriage return and new line before data content
            body.append("Content-Type: \(element.contentType)\r\n\r\n".data(using: .utf8)!)
            body.append(element.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        // Last boundary line ends in -- as per https://tools.ietf.org/html/rfc2046#section-5.1.1
        body.append("--\(HTTPCall.boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

