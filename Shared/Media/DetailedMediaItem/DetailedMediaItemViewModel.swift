//
//  DetailedMediaItemViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 12.10.2022.
//

import SwiftUI
import OrderedCollections

@MainActor
final class DetailedMediaItemViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<DetailedMedia>.fetching
    @Published private(set) var isFetching = true
    
    private let rezkaAPI = MediaRezkaApi()
    
    private let cache: DiskCache<[DetailedMedia]> = .init(filename: "xcadmediacache", expirationInterval: 30 * 60)
    
    private let historyStorage = CloudKitDataStore<[DetailedHistoryMedia]>(recordType: "HistoryMedia", recordName: "history")
    
    private let settingsStorage = CloudKitDataStore<MediaSettings>(recordType: "SettingsMedia", recordName: "settings")
    
    private var settings: MediaSettings = .init()
    
    private var history: [DetailedHistoryMedia] = .init()
    
    let media: Media
    private var detailedMedia: DetailedMedia {
        phase.value ?? DetailedMedia.previewData
    }
    
    private(set) var historyMedia: DetailedHistoryMedia
    
    private(set) var router = HLSURLRouter(cache: URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "AVPlayerCache"))
    
    private(set) var loader: HLSCachingLoader
    
    init(media: Media) {
        self.media = media
        self.loader = HLSCachingLoader(router: router, cache: router.cache)
        historyMedia = DetailedHistoryMedia(mediaId: 0)
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
        let dropCount = max(detailedMedia.description.count - 512, 0)
        if dropCount == 0 {
            return detailedMedia.description
        } else {
            return String(detailedMedia.description.dropLast(dropCount)) + "..."
        }
    }
    
    var currentTranslationTitle: String? {
        detailedMedia.translations.isEmpty == false ? detailedMedia.translations[historyMedia.translation] : nil
    }
    
    var nextSeasonId: Int? {
        guard let seasons = seasonsInCurrentTranslation, let currentSeason = seasons.first(where: { $1 == currentSeasonTitle }) else {
            return nil
        }
        
        let nextId = currentSeason.key + 1
        
        guard nextId <= seasons.count else {
            return nil
        }
        
        return nextId
    }
    
    var currentSeasonTitle: String {
        guard let currentSeason = historyMedia.season else {
            return "-"
        }
        
        return season?.seasons[currentSeason] ?? "-"
    }
    
    var seasonsInCurrentTranslation: OrderedDictionary<Int, String>? {
        return detailedMedia.seasons(in: historyMedia.translation)
    }
    
    var currentEpisodeTitle: String {
        episode?.title ?? "-"
    }
    
    var nextEpisodeId: Int? {
        guard let id = episode?.id, let episodesCount = episodes?.count else {
            return nil
        }
        
        let nextId = id + 1
        
        guard nextId <= episodesCount else {
            return nil
        }
        
        return nextId
    }
    
    func setQuality(_ quality: Media.Quality) {
        historyMedia.quality = quality
        phase = .success(detailedMedia)
        settings.quality = quality
        Task {
            try? await settingsStorage.save(settings)
        }
    }
    
    private(set) var streams: StreamMedia?
    var stream: String {
        streams?.stream(historyMedia.quality) ?? ""
    }
    
    func loadDetailedMedia() async {
        if Task.isCancelled { return }
        
        try? await cache.loadFromDisk()
        history = (try? await historyStorage.load()) ?? .init()
        settings = (try? await settingsStorage.load()) ?? .init()
        
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
            var detailedMedia = try await rezkaAPI.fetchDetails(from: media)
            if Task.isCancelled { return }
            
            guard var currentTranslationId = detailedMedia.translations.keys.first else {
                phase = .failure(DataError.generate(for: .rezkaConstantsApi, error: .empty))
                return
            }
            
            let preferedTranslation = settings.translationId
            if detailedMedia.translations.keys.contains(preferedTranslation) {
                currentTranslationId = preferedTranslation
            }
            
            if let history = history.first(where: { $0.mediaId ==  detailedMedia.mediaId }) {
                historyMedia = history
                currentTranslationId = history.translation
                detailedMedia = try await rezkaAPI.fetchDetails(from: media, translation: currentTranslationId)
            } else {
                historyMedia = DetailedHistoryMedia(mediaId: detailedMedia.mediaId, translation: currentTranslationId)
                
                if media.isSeries {
                    historyMedia.season = 1
                    historyMedia.episode = 1
                }
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
        detailedMedia.seasons[historyMedia.translation]
    }
    
    var episodes: [Episode]? {
        guard let currentSeason = historyMedia.season else {
            return nil
        }
        
        return season?.episodes[currentSeason]
    }
    
    var episode: Episode? {
        episodes?.first{ $0.id == historyMedia.episode }
    }
    
    func setCurrentTranslation(id: Int, mediaId: Int? = nil) async throws {
        
        historyMedia.translation = id
        
        if media.isSeries, mediaId == nil {
            historyMedia.season = 1
            historyMedia.episode = 1
        }
        
        try await updateStreams(of: mediaId ?? detailedMedia.mediaId)
        
        if media.isSeries, (mediaId == nil || seasonsInCurrentTranslation == nil) {
            phase = .success(try await rezkaAPI.fetchSeriesDetails(for: detailedMedia, translation: id))
        } else {
            phase = .success(detailedMedia)
        }
        
        settings.translationId = id
        try await settingsStorage.save(settings)
    }
    
    func setCurrentSeason(id: Int) async throws {
        historyMedia.season = id
        
        try await setCurrentEpisode(id: historyMedia.episode ?? 1)
    }
    
    func setCurrentEpisode(id: Int) async throws {
        historyMedia.episode = id
        
        try await updateStreams(of: detailedMedia.mediaId)
        
        phase = .success(detailedMedia)
    }
    
    private func updateStreams(of mediaId: Int) async throws {
        streams = try await rezkaAPI.stream(mediaId: mediaId, translationId: historyMedia.translation, season: historyMedia.season, episode: historyMedia.episode)
        
        let lastQ: Media.Quality = settings.quality
        let bestQ: Media.Quality = streams?.bestQualityId ?? .unknown
        
        if lastQ != .unknown && bestQ > lastQ {
            historyMedia.quality = lastQ
        }
        else{
            historyMedia.quality = bestQ
        }
        
        history.removeAll { $0.mediaId == mediaId }
        history.append(historyMedia)
        
        try await historyStorage.save(history)
    }
}
