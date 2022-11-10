//
//  MediaContentViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 04.10.2022.
//

import SwiftUI

@MainActor
class MediaContentViewModel: ObservableObject {
    
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
    
    init(category: Category = .general, subCategories: [SubCategoryList]? = nil) {
        self.category = category
        self.subCategories = subCategories
        self.selectedSubCategory = subCategories?.first
    }
    
    func setSubCategory(_ subCategory: SubCategoryList) async {
        selectedSubCategory = subCategory
        await loadMedias()
    }
    
    func loadMedias() async {
        if Task.isCancelled { return }
        if let articles = await cache.value(forKey: "new_media_list") {
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
        isFetching = true
        do {
            let categoryMedias = try await rezkaAPI.fetch(from: category, subCategory: selectedSubCategory, page: page)
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
