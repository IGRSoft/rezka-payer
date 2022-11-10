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
        URL(string: url)!
    }
    
    var coverURL: URL {
        URL(string: coverUrl)!
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
        let previewDataURL = Bundle.main.url(forResource: "medias", withExtension: "json")!
        let data = try! Data(contentsOf: previewDataURL)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        let apiResponse = try! jsonDecoder.decode(MediaRezkaAPIResponse.self, from: data)
        return apiResponse.medias
    }
    
    static var previewCategoryArticles: [CategoryMedias] {
        let articles = previewData
        return Category.allCases.map {
            .init(category: $0, articles: articles.shuffled())
        }
    }
}
