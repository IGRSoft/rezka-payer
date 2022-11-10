//
//  MediaSearchContentViewModel.swift
//  rezka-player
//
//  Created by vitalii on 10.11.2022.
//  Copyright © 2022 IGR Soft. All rights reserved.
//

import SwiftUI

@MainActor
class MediaSearchContentViewModel: ObservableObject {
    
    @Published var phase = DataFetchPhase<[Media]>.fetching
    
    private let category: Category
    
    private(set) var subCategories: [SubCategoryList]?
    private(set) var selectedSubCategory: SubCategoryList?
    private var searchText: String?
    
    private var page = 1
    @Published private(set) var isFetching = true
    
    private let rezkaAPI = MediaRezkaApi()
    
    private let cache: DiskCache<[Media]> = .init(filename: "xcamediacache", expirationInterval: 5 * 60)
    
    var newMedias: [Media] {
        phase.value ?? []
    }
    
    init(category: Category = .search, search: String = "") {
        self.category = category
        self.searchText = search
    }
    
    func updateSearch(text: String) async {
        searchText = text
        await searchMedias()
    }
    
    func searchMedias() async {
        if Task.isCancelled { return }
        if let articles = await cache.value(forKey: "search_media_list") {
            phase = .success(articles)
        }
        
        phase = .fetching
        self.page = 1
        
        await loadData(page: page)
    }
    
    func loadMore() async {
        phase = .fetchingNextPage(newMedias)
        
        await loadData(page: page)
    }
    
    private func loadData(page: Int = 1) async {
        guard let search = searchText, search.isEmpty == false else {
            phase = .success([])
            return
        }
        
        isFetching = true
        do {
            let categoryMedias = try await rezkaAPI.search(for: search, page: page)
            
            if Task.isCancelled { return }
            let medias = (page == 1 ? [] : newMedias) + categoryMedias
            await cache.setValue(medias, forKey: "new_media_list")
            try? await cache.saveToDisk()
            
            phase = .success(medias)
            self.page = page + 1
            isFetching = false
            
        } catch {
            if Task.isCancelled { return }
            phase = .failure(error)
            isFetching = false
        }
    }
}
