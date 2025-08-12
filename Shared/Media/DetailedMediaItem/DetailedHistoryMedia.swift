//
//  DetailedHistoryMedia.swift
//  rezka-player
//
//  Created by vitalii on 30.03.2023.
//  Copyright © 2023 IGR Soft. All rights reserved.
//

import Foundation

final class DetailedHistoryMedia: ObservableObject, Codable {
    
    private(set) var mediaId: Int
    
    @Published var translation: Int
    
    @Published var season: Int?
    
    @Published var episode: Int?
    
    @Published var quality: Media.Quality = Media.Quality.unknown
    
    init(mediaId: Int, translation: Int = 0, season: Int? = nil, episode: Int? = nil, quality: Media.Quality = Media.Quality.unknown) {
        self.mediaId = mediaId
        self.translation = translation
        self.season = season
        self.episode = episode
        self.quality = quality
    }
    
    enum CodingKeys: String, CodingKey {
        case mediaId, translation, season, episode, quality
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        mediaId = try values.decode(Int.self, forKey: .mediaId)
        translation = try values.decode(Int.self, forKey: .translation)
        season = try? values.decodeIfPresent(Int.self, forKey: .season)
        episode = try? values.decodeIfPresent(Int.self, forKey: .episode)
        quality = try values.decode(Media.Quality.self, forKey: .quality)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mediaId, forKey: .mediaId)
        try container.encode(translation, forKey: .translation)
        try container.encode(season, forKey: .season)
        try container.encode(episode, forKey: .episode)
        try container.encode(quality, forKey: .quality)
    }
}

extension DetailedHistoryMedia: Equatable {
    static func == (lhs: DetailedHistoryMedia, rhs: DetailedHistoryMedia) -> Bool {
        return lhs.mediaId == rhs.mediaId &&
            lhs.translation == rhs.translation &&
            lhs.season == rhs.season &&
            lhs.episode == rhs.episode &&
            lhs.quality == rhs.quality
    }
}
