//
//  MediaRezkaApi.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import Foundation

struct MediaRezkaApi {

    private let session = URLSession.shared
    
    func fetch(from category: Category, subCategory: SubCategoryList?, page: Int = 1) async throws -> [Media] {
        try await fetchMedias(from: generateNewMediaURL(from: category, subCategory: subCategory, page: page))
    }
    
    func fetchDetails(from media: Media) async throws -> DetailedMedia {
        var detailedMedia = try await fetchMedia(from: media.mediaURL)
        guard let currentTranslationId = detailedMedia.translations.keys.first else {
            throw DataError.generate(for: .rezkaConstantsApi, error: .mapping)
        }
        
        if media.isSeries {
            detailedMedia = try await fetchSeriesDetails(for: detailedMedia, translation: currentTranslationId)
        }
                
        return detailedMedia
    }
    
    func fetchSeriesDetails(for media: DetailedMedia, translation: Int) async throws -> DetailedMedia {
        var detailedMedia = media
        let seasons = try await seasons(mediaId: detailedMedia.mediaId, translationId: translation)
        detailedMedia.setup(seasons: seasons, for: translation)
                
        return detailedMedia
    }
    
    func search(for query: String, page: Int = 1) async throws -> [Media] {
        try await fetchMedias(from: generateSearchURL(from: query, page: page))
    }
    
    func seasons(mediaId: Int, translationId: Int) async throws -> SeasonsData {
        try await fetchSeasons(mediaId: mediaId, translationId: translationId)
    }
    
    func stream(mediaId: Int, translationId: Int, season: Int?, episode: Int?) async throws -> StreamMedia {
        let request = streamRequest(mediaId: mediaId, translationId: translationId, season: season, episode: episode)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw DataError.generate(for: .rezkaConstantsApi, error: .bad)
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let dirtyBase64 = String(decoding: data, as: UTF8.self)
            guard !dirtyBase64.isEmpty else {
                throw DataError.generate(for: .rezkaConstantsApi, error: .empty)
            }
            
            return try StreamRezkaApiResponse(from: dirtyBase64, isJson: true).streams
        default:
            throw DataError.generate(for: .rezkaConstantsApi, error: .server)
        }
    }
    
    private func fetchMedias(from url: URL) async throws -> [Media] {
        let request = request(for: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw DataError.generate(for: .rezkaConstantsApi, error: .bad)
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let html = String(decoding: data, as: UTF8.self)
            guard !html.isEmpty else {
                throw DataError.generate(for: .rezkaConstantsApi, error: .empty)
            }
            
            return try MediaRezkaAPIResponse(from: html).medias
        default:
            throw DataError.generate(for: .rezkaConstantsApi, error: .server)
        }
    }
    
    private func fetchMedia(from url: URL) async throws -> DetailedMedia {
        let request = request(for: url)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw DataError.generate(for:. rezkaConstantsApi, error: .bad)
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let html = String(decoding: data, as: UTF8.self)
            guard !html.isEmpty else {
                throw DataError.generate(for: .rezkaConstantsApi, error: .empty)
            }
            
            return try DetailedMediaRezkaAPIResponse(from: html).detailedMedia
        default:
            throw DataError.generate(for: .rezkaConstantsApi, error: .server)
        }
    }
    
    private func fetchSeasons(mediaId: Int, translationId: Int) async throws -> SeasonsData {
        let request = seasonsRequest(mediaId: mediaId, translationId: translationId)
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw DataError.generate(for: .rezkaConstantsApi, error: .bad)
        }
        
        switch response.statusCode {
            
        case (200...299), (400...499):
            let html = String(decoding: data, as: UTF8.self)
            guard !html.isEmpty else {
                throw DataError.generate(for:.rezkaConstantsApi, error: .empty)
            }
            
            guard let object = try? JSONDecoder().decode(SeasonsData.self , from: data) else {
                throw DataError.generate(for: .rezkaConstantsApi, error: .mapping)
            }
            
            return object
            
        default:
            throw DataError.generate(for: .rezkaConstantsApi, error: .server)
        }
    }
    
    private func generateSearchURL(from query: String, page: Int = 1) -> URL {
        var url = "\(RezkaConstantsApi.server)/search/?do=search&subaction=search&q=\(query)"
        
        if page > 1 {
            url += "&page=\(page)"
        }
        
        return URL(string: url)!
    }
    
    private func generateNewMediaURL(from category: Category, subCategory: SubCategoryList?, page: Int = 1) -> URL {
        var url = RezkaConstantsApi.server
        if page > 1 {
            url += "/page/\(page)"
        }
        
        if category != .general {
            url += "/\(category.rawValue)"
        }
        if let subCategory = subCategory {
            url += "/\(subCategory.uri)"
        }
        
        return URL(string: url)!
    }
    
    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = ApiConstants.HttpMethod.post.rawValue
        request.setValue(ApiConstants.userAgent, forHTTPHeaderField: ApiConstants.userAgentKey)
        request.addValue(ApiConstants.defaultContentType, forHTTPHeaderField: ApiConstants.contentTypeKey)
        return request
    }
    
    private func seasonsRequest(mediaId: Int, translationId: Int) -> URLRequest {
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [URLQueryItem(name: "id", value: "\(mediaId)"),
                                     URLQueryItem(name: "translator_id", value: "\(translationId)"),
                                     URLQueryItem(name: "action", value: "get_episodes"),
        ]
        
        var request = URLRequest(url: URL(string: "\(RezkaConstantsApi.server)/ajax/get_cdn_series/")!)
        request.httpMethod = ApiConstants.HttpMethod.post.rawValue
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        request.setValue(ApiConstants.userAgent, forHTTPHeaderField: ApiConstants.userAgentKey)
        request.addValue(ApiConstants.formContentType, forHTTPHeaderField: ApiConstants.contentTypeKey)
        request.addValue(ApiConstants.AcceptTypeJson, forHTTPHeaderField: ApiConstants.AcceptTypeKey)
        return request
    }
    
    private func streamRequest(mediaId: Int, translationId: Int, season: Int?, episode: Int?) -> URLRequest {
        var bodyComponents = URLComponents()
        var additionalData = [URLQueryItem]()
        
        if let season = season, let episode = episode {
            additionalData = [URLQueryItem(name: "season", value: "\(season)"),
                              URLQueryItem(name: "episode", value: "\(episode)"),
                              URLQueryItem(name: "action", value: "get_stream")]
        } else {
            additionalData = [URLQueryItem(name: "action", value: "get_movie")]
        }
        
        bodyComponents.queryItems = [URLQueryItem(name: "id", value: "\(mediaId)"),
                                     URLQueryItem(name: "translator_id", value: "\(translationId)")]
        
        bodyComponents.queryItems?.append(contentsOf: additionalData)
        
        var request = URLRequest(url: URL(string: "\(RezkaConstantsApi.server)/ajax/get_cdn_series/")!)
        request.httpMethod = ApiConstants.HttpMethod.post.rawValue
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        request.setValue(ApiConstants.userAgent, forHTTPHeaderField: ApiConstants.userAgentKey)
        request.addValue(ApiConstants.formContentType, forHTTPHeaderField: ApiConstants.contentTypeKey)
        request.addValue(ApiConstants.AcceptTypeJson, forHTTPHeaderField: ApiConstants.AcceptTypeKey)
        return request
    }
}
