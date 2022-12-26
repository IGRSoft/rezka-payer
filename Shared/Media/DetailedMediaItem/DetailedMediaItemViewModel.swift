//
//  DetailedMediaItemViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 12.10.2022.
//

import SwiftUI
import OrderedCollections

@MainActor
class DetailedMediaItemViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<DetailedMedia>.fetching
    @Published private(set) var isFetching = true
    
    private let rezkaAPI = MediaRezkaApi()
    
    private let cache: DiskCache<[DetailedMedia]> = .init(filename: "xcadmediacache", expirationInterval: 5 * 60)
    
    let media: Media
    private var detailedMedia: DetailedMedia {
        phase.value ?? DetailedMedia.previewData
    }
    
    init(media: Media) {
        self.media = media
    }
    
    var title: String {
        detailedMedia.title
    }
    
    var originalTitle: String {
        detailedMedia.titleOriginal
    }
    
    var coverUrl: URL? {
        URL(string: detailedMedia.coverUrl)
    }
    
    var info: OrderedDictionary<String, String> {
        detailedMedia.info
    }
    
    var description: String {
        detailedMedia.description
    }
    
    private(set) var currentTranslation = 0
    
    var currentTranslationTitle: String? {
        detailedMedia.translations.isEmpty == false ? detailedMedia.translations[currentTranslation] : nil
    }
    
    private(set) var currentSeason: Int?
    var currentSeasonTitle: String {
        guard let currentSeason = currentSeason else {
            return "-"
        }
        
        return season?.seasons[currentSeason] ?? "-"
    }
    
    var seasonsInCurrentTranslation: OrderedDictionary<Int, String>? {
        return detailedMedia.seasons(in: currentTranslation)
    }
    
    private(set) var currentEpisode: Int?
    var currentEpisodeTitle: String {
        episode?.title ?? "-"
    }
    
    private(set) var currentQuality = Media.Quality.unknown
    
    func setQuality(_ quality: Media.Quality) {
        currentQuality = quality
        phase = .success(detailedMedia)
    }
    
    private(set) var streams: StreamMedia?
    var stream: String {
        streams?.stream(currentQuality) ?? ""
    }
    
    func loadDetailedMedia() async {
        if Task.isCancelled { return }
        if let medias = await cache.value(forKey: "detailed_media_\(media.id)"), let media = medias.first {
            phase = .success(media)
        } else {
            phase = .fetching
        }
        
        await loadData()
    }
    
    private func loadData() async {
        isFetching = true
        do {
            let detailedMedia = try await rezkaAPI.fetchDetails(from: media)
            if Task.isCancelled { return }
            
            guard let currentTranslationId = detailedMedia.translations.keys.first else {
                phase = .failure(DataError.generate(for: .rezkaConstantsApi, error: .empty))
                return
            }
            
            if media.isSeries {
                currentSeason = 1
                currentEpisode = 1
            }
            
            try? await setCurrentTranslation(id: currentTranslationId, mediaId: detailedMedia.mediaId)
            
            await cache.setValue([detailedMedia], forKey: "detailed_media_\(media.id)")
            try? await cache.saveToDisk()
            
            phase = .success(detailedMedia)
            isFetching = false
            
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
            isFetching = false
        }
    }
    
    var translations: OrderedDictionary<Int, String> {
        detailedMedia.translations
    }
    
    var season: SeasonsData? {
        detailedMedia.seasons[currentTranslation]
    }
    
    var episodes: [Episode]? {
        guard let currentSeason = currentSeason else {
            return nil
        }
        
        return season?.episodes[currentSeason]
    }
    
    var episode: Episode? {
        episodes?.first{ $0.id == currentEpisode }
    }
    
    func setCurrentTranslation(id: Int, mediaId: Int? = nil) async throws {
        currentTranslation = id
        
        if media.isSeries, mediaId == nil {
            currentSeason = 1
            currentEpisode = 1
        }
        
        try await updateStreams(of: mediaId ?? detailedMedia.mediaId)
        
        if media.isSeries, mediaId == nil {
            phase = .success(try await rezkaAPI.fetchSeriesDetails(for: detailedMedia, translation: id))
        } else {
            phase = .success(detailedMedia)
        }
    }
    
    func setCurrentSeason(id: Int) async throws {
        currentSeason = id
        currentEpisode = 1
        
        try await updateStreams(of: detailedMedia.mediaId)
        
        phase = .success(detailedMedia)
    }
    
    func setCurrentEpisode(id: Int) async throws {
        currentEpisode = id
        
        try await updateStreams(of: detailedMedia.mediaId)
        
        phase = .success(detailedMedia)
    }
    
    private func updateStreams(of mediaId: Int) async throws {
        streams = try await rezkaAPI.stream(mediaId: mediaId, translationId: currentTranslation, season: currentSeason, episode: currentEpisode)
        
        currentQuality = streams?.bestQualityId ?? .unknown
    }
}
