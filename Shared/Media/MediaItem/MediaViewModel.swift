//
//  MediaViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import SwiftUI

@MainActor
class MediaViewModel: ObservableObject {
    
    @Published private(set) var bookmarks: [Media] = []
    private let bookmarkStore = PlistDataStore<[Media]>(filename: "bookmarks")
    
    static let shared = MediaViewModel()
    private init() {
        Task {
            await load()
        }
    }
    
    private func load() async {
        bookmarks = await bookmarkStore.load() ?? []
    }
    
    func isBookmarked(for article: Media) -> Bool {
        bookmarks.first { article.id == $0.id } != nil
    }
    
    func addBookmark(for article: Media) {
        guard !isBookmarked(for: article) else {
            return
        }
        
        bookmarks.insert(article, at: 0)
        bookmarkUpdated()
    }
    
    func removeBookmark(for article: Media) {
        guard let index = bookmarks.firstIndex(where: { $0.id == article.id }) else {
            return
        }
        bookmarks.remove(at: index)
        bookmarkUpdated()
    }
    
    func removeAllBookmarks() {
        bookmarks.removeAll()
        bookmarkUpdated()
    }
    
    func toggleBookmark(for article: Media) {
        if isBookmarked(for: article) {
            removeBookmark(for: article)
        } else {
            addBookmark(for: article)
        }
    }
    
    private func bookmarkUpdated() {
        let bookmarks = self.bookmarks
        Task {
            await bookmarkStore.save(bookmarks)
        }
    }
}
