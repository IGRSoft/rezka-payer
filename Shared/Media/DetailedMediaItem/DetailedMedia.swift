//
//  DetailedMedia.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 12.10.2022.
//

import Foundation
import OrderedCollections

struct DetailedMedia {
    private(set) var id = UUID()
    
    let mediaId: Int
    
    let title: String
    let titleOriginal: String
    
    let info: OrderedDictionary<String, String>
    let description: String
    
    let translations: OrderedDictionary<Int, String>
    
    private(set) var seasons: [Int: SeasonsData] = [:]
    func seasons(in translation: Int) -> OrderedDictionary<Int, String>? {
        return seasons[translation]?.seasons
    }
    
    func episodesIn(in season: Int, translation: Int) -> [Episode]? {
        return seasons[translation]?.episodes[season]
    }
    
    let coverUrl: String
    
    mutating func setup(seasons: SeasonsData, for translation: Int) {
        self.seasons[translation] = seasons
    }
}

extension DetailedMedia: Codable {}
extension DetailedMedia: Equatable {
    static func == (lhs: DetailedMedia, rhs: DetailedMedia) -> Bool {
        return lhs.id == rhs.id
    }
}
extension DetailedMedia: Identifiable {}

extension DetailedMedia {
    
    static var previewData: DetailedMedia {
        return DetailedMedia(mediaId: .zero, title: "", titleOriginal: "", info: [:], description: "", translations: [:], seasons: [:], coverUrl: "")
    }
}
