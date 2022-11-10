//
//  ContentViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[CategoryList]>.fetching
    @Published private(set) var isFetching = true
    
    private let api = NavigationRezkaApi()
    
    private let cache: DiskCache<[CategoryList]> = .init(filename: "navigationcache", expirationInterval: 5 * 60)
    
    var categories: [CategoryList] {
        phase.value ?? []
    }
    
    func load() async {
        if Task.isCancelled { return }
        if let categories = await cache.value(forKey: "categories_list") {
            phase = .success(categories)
        }
        
        phase = .fetching
        
        await loadNavigation()
    }
    
    private func loadNavigation() async {
        isFetching = true
        do {
            let categories = try await api.fetch()
            if Task.isCancelled { return }
            await cache.setValue(categories, forKey: "categories_list")
            try? await cache.saveToDisk()
            
            phase = .success(categories)
            isFetching = false
            
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
            isFetching = false
        }
    }
}
