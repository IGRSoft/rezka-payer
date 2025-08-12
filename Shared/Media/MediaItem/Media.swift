//
//  Media.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import Foundation

let activityTypeViewKey = "com.rezka-player.media.view"
let activityURLKey = "media.url.key"

struct Media {
    enum Quality: String, Codable {
        case p1080u = "1080p Ultra"
        case p1080 = "1080p"
        case p720 = "720p"
        case p480 = "480p"
        case p360 = "360p"
        case unknown
    }
    
    var id = UUID()
    
    let title: String
    let url: String
    var uri: String {
        let components = url.components(separatedBy: "/")
        return components.suffix(from: 3).joined(separator: "/")
    }
    let descriptionShort: String
    let description: String?
    let coverUrl: String
    let seriesInfo: String?
    let category: Category
    let quality: Quality
    
    var descriptionText: String {
        descriptionShort
    }
    
    var mediaURL: URL {
        URL(string: "\(RezkaConstantsApi.server)/\(uri)")!
    }
    
    var coverURL: URL? {
        URL(string: coverUrl)
    }
    
    var isSeries: Bool {
        seriesInfo != nil
    }
}

extension Media: Codable {}
extension Media: Equatable {}
extension Media: Identifiable {}

extension Media {
    
    static var previewData: [Media] {
        [
            .init(id: .init(uuidString: "EEEAAAF2-DA0B-4A8F-8F8F-FFFADA2DDDD4")!, title: "one", url: "https://example.com", descriptionShort: "description short", description: "description", coverUrl: "", seriesInfo: "", category: .films, quality: .unknown)
        ]
    }
    
    static var previewCategoryArticles: [CategoryMedias] {
        let articles = previewData
        return Category.allCases.map {
            .init(category: $0, medias: articles.shuffled())
        }
    }
}

extension Media {
    static var empty: Media {
        .init(id: .init(uuidString: "EEEAAAF2-DA0B-4A8F-8F8F-FFFADA2DDDD4")!, title: "", url: "", descriptionShort: "", description: "", coverUrl: "", seriesInfo: "", category: .loadMore, quality: .unknown)
    }
}


extension Media.Quality: Comparable, Equatable{
    
    static func index(of aStatus: Media.Quality) -> Int {
        switch aStatus {
        case .p360: 1
        case .p480: 2
        case .p720: 3
        case .p1080: 4
        case .p1080u: 5
        default: 0
        }
    }
    
    static func > (lhs: Media.Quality, rhs: Media.Quality) -> Bool {
        Media.Quality.index(of: lhs) >  Media.Quality.index(of: rhs)
    }
    
    static func < (lhs: Media.Quality, rhs: Media.Quality) -> Bool {
        Media.Quality.index(of: lhs) <  Media.Quality.index(of: rhs)
    }
    
    static func == (lhs: Media.Quality, rhs: Media.Quality) -> Bool {
        Media.Quality.index(of: lhs) ==  Media.Quality.index(of: rhs)
    }
}
