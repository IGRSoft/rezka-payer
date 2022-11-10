//
//  NavigationRezkaApi.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import Foundation

struct NavigationRezkaApi {

    private let session = URLSession.shared
    
    func fetch() async throws -> [CategoryList] {
        try await fetchNavigation(from: generateNavigationUrl())
    }
    
    private func fetchNavigation(from url: URL) async throws -> [CategoryList] {
        let request = request(for: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw DataError.generate(for: .navigationRezkaApi, error: .bad)
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let html = String(decoding: data, as: UTF8.self)
            guard !html.isEmpty else {
                throw DataError.generate(for: .navigationRezkaApi, error: .empty)
            }
            
            return try NavigationRezkaApiResponse(from: html).categories
        default:
            throw DataError.generate(for: .navigationRezkaApi, error: .server)
        }
    }
    
    func generateNavigationUrl() -> URL {
        return URL(string: RezkaConstantsApi.server)!
    }
    
    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = ApiConstants.HttpMethod.post.rawValue
        request.setValue(ApiConstants.userAgent, forHTTPHeaderField: ApiConstants.userAgentKey)
        request.addValue(ApiConstants.defaultContentType, forHTTPHeaderField: ApiConstants.contentTypeKey)
        return request
    }
}
