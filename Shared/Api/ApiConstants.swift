//
//  ApiConstants.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import Foundation

struct ApiConstants {
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum ResponseError: String, CaseIterable {
        case `default`
        case empty = "Empty Response"
        case bad = "Bad Response"
        case server = "A server error occurred"
        case mapping = "Can't map response to model"
        case unknownStreamQuality = "Wrong Stream Quality"
        case emptySearch = "Please enter searched text"
        
        var code: Int {
            return 12300 + (self.index ?? .zero)
        }
    }
        
    enum Domains: String {
        case rezkaConstantsApi = "RezkaConstantsApi"
        case navigationRezkaApi = "NavigationRezkaApi"
        case streamRezkaApi = "StreamRezkaApi"
    }
    
    static let contentTypeKey = "Content-Type"
    static let defaultContentType = "text/html; charset=UTF-8"
    static let formContentType = "application/x-www-form-urlencoded"
    
    
    static let userAgentKey = "User-Agent"
    static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Safari/605.1.15"
    
    static let AcceptTypeKey = "Accept"
    static let AcceptTypeJson = "application/json"
}

struct DataError {
    static func generate(for domain: ApiConstants.Domains, error: ApiConstants.ResponseError) -> Error {
        NSError(domain: domain.rawValue, code: error.code, userInfo: [NSLocalizedDescriptionKey: error.rawValue])
    }
}
