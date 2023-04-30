//
//  MediaCategoriesViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 16.08.2022.
//

import SwiftUI

@MainActor
class MediaCategoriesViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[CategoryMedias]>.fetching
    
    private let rezkaAPI = MediaRezkaApi()
    
    private let cache: DiskCache<[CategoryMedias]> = .init(filename: "xcamediacache", expirationInterval: 30 * 60)
    
    var categoryMedias: [CategoryMedias] {
        phase.value ?? []
    }
    
    func loadCategoryMedias() async {
        if Task.isCancelled { return }
        if let articles = await cache.value(forKey: "media_list") {
            phase = .success(articles)
            return
        }
        
        phase = .fetching

//        do {
//            let categoryMedias = try await rezkaAPI.fetchAllCategoryArticles()
//            if Task.isCancelled { return }
//            await cache.setValue(categoryMedias, forKey: "media_list")
//            try? await cache.saveToDisk()
//
//            phase = .success(categoryMedias)
//        } catch {
//            if Task.isCancelled { return }
//            phase = .failure(error)
//        }
    }
}
