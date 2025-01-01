//
//  StreamRezkaApiResponse.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 23.10.2022.
//

import Foundation
import SwiftSoup

private struct StreamData: Codable {
    let success: Bool
    let message: String
    let url: String?
    let quality: String
    let subtitle: String?
    let subtitlesList: [String: String]?
    let subtitleDefault: String?
    let thumbnails: String
    
    enum CodingKeys: String, CodingKey {
        case success, message, url, quality, subtitle
        case subtitlesList = "subtitle_lns"
        case subtitleDefault = "subtitle_def"
        case thumbnails
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decode(Bool.self, forKey: .success)
        message = try values.decode(String.self, forKey: .message)
        url = try values.decode(String.self, forKey: .url)
        quality = try values.decode(String.self, forKey: .quality)
        subtitle = try? values.decode(String.self, forKey: .subtitle)
        subtitlesList = try? values.decode([String: String].self, forKey: .subtitlesList)
        subtitleDefault = try? values.decode(String.self, forKey: .subtitleDefault)
        thumbnails = try values.decode(String.self, forKey: .thumbnails)
    }
}

// MARK: - Seasons
struct StreamMedia: Codable {
    var bestQualityId: Media.Quality {
        if let p = p1080u, p.isEmpty == false {
            .p1080u
        } else if let p = p1080, p.isEmpty == false {
            .p1080
        } else if let p = p720, p.isEmpty == false {
            .p720
        } else if let p = p480, p.isEmpty == false {
            .p480
        } else if let p = p360, p.isEmpty == false {
            .p360
        } else {
            //assert(false, "wrong stream data")
            .p360
        }
    }
    
    var bestQualityUrl: [String] {
        if let p = p1080u, p.isEmpty == false {
            p
        } else if let p = p1080, p.isEmpty == false {
            p
        } else if let p = p720, p.isEmpty == false {
            p
        } else if let p = p480, p.isEmpty == false {
            p
        } else if let p = p360, p.isEmpty == false {
            p
        } else {
            //assert(false, "wrong stream data")
            []
        }
    }
    
    var qualities: [Media.Quality]? {
        var qualities = [Media.Quality]()
        let list: [Media.Quality] = [.p1080u, .p1080, .p720, .p480, .p360]
        for q in list {
            if let _ = stream(q) {
                qualities.append(q)
            }
        }
        
        return qualities.isEmpty ? nil : qualities
    }
    
    private let p1080u: [String]?
    private let p1080: [String]?
    private let p720: [String]?
    private let p480: [String]?
    private let p360: [String]?
    
    init(p1080u: [String]? = nil, p1080: [String]? = nil, p720: [String]? = nil, p480: [String]? = nil, p360: [String]? = nil) {
        self.p1080u = p1080u
        self.p1080 = p1080
        self.p720 = p720
        self.p480 = p480
        self.p360 = p360
    }
    
    func stream(_ quality: Media.Quality) -> String? {
        switch quality {
        case .p1080u: p1080u?.first
        case .p1080: p1080?.first
        case .p720: p720?.first
        case .p480: p480?.first
        case .p360: p360?.first
        case .unknown: nil
        }
    }
    
    func alternativeStream(_ quality: Media.Quality) -> String? {
        switch quality {
        case .p1080u: p1080u?.last
        case .p1080: p1080?.last
        case .p720: p720?.last
        case .p480: p480?.last
        case .p360: p360?.last
        case .unknown:
            //assert(false, "wrong stream data")
            nil
        }
    }
}

struct StreamRezkaApiResponse: Decodable {
    let streams: StreamMedia
    
    init(from dirtyBase64: String, isJson: Bool = false) throws {
        var cleanedBase64 = dirtyBase64
        
        if isJson {
            guard let data = dirtyBase64.data(using: .utf8), let object = try? JSONDecoder().decode(StreamData.self , from: data) else {
                throw DataError.generate(for: .rezkaConstantsApi, error: .mapping)
            }
            
            guard let url = object.url else {
                throw DataError.generate(for: .rezkaConstantsApi, error: .mapping)
            }
            
            cleanedBase64 = url
        }
        
        cleanedBase64 = cleanedBase64.replacing("#h", with: "")
        
        let trashList = ["@", "#", "!", "^", "$"]
        var trashItems = [String]()
        for symbol1 in trashList {
            for symbol2 in trashList {
                let trash1 = "\(symbol1)\(symbol2)".toBase64()
                trashItems.append(trash1)
            }
            for symbol2 in trashList {
                for symbol3 in trashList {
                    let trash2 = "\(symbol1)\(symbol2)\(symbol3)".toBase64()
                    trashItems.append(trash2)
                }
            }
        }
        
        cleanedBase64 = cleanedBase64.split(separator: "//_//").joined()
        
        trashItems.forEach { trash in
            cleanedBase64 = cleanedBase64.replacing(trash, with: "")
        }
                
        var p1080u: [String]?
        var p1080: [String]?
        var p720: [String]?
        var p480: [String]?
        var p360: [String]?
        
        let streamsElements = cleanedBase64.fromBase64()?.split(separator: ",")
        try? streamsElements?.forEach({ stream in
            let items = stream.split(separator: "]")
            let tempQuality = items.first ?? ""
            let tempStreams = items.last ?? ""
            
            var type: Media.Quality = .unknown
            let qualityComponents = tempQuality.split(separator: "[")
            if let quality = qualityComponents.last {
                type = Media.Quality(rawValue: String(quality)) ?? .unknown
            }
            
            guard type != .unknown else {
                throw DataError.generate(for: .streamRezkaApi, error: .unknownStreamQuality)
            }
            
            let urls = tempStreams.split(separator: " or ").compactMap { String($0) }
            
            switch type {
            case .p1080u: p1080u = urls
            case .p1080: p1080 = urls
            case .p720: p720 = urls
            case .p480: p480 = urls
            case .p360: p360 = urls
            case .unknown: break
            }
        })
        
        self.streams = StreamMedia(p1080u: p1080u, p1080: p1080, p720: p720, p480: p480, p360: p360)
    }
}
