//
//  MediaBookmarksViewModel.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 16.08.2022.
//

import SwiftUI

@MainActor
class MediaBookmarksViewModel: ObservableObject {
    
    @Published private(set) var bookmarks: [Media] = []
    private let bookmarkStore = PlistDataStore<[Media]>(filename: "bookmarks")
    
    static let shared = MediaBookmarksViewModel()
    private init() {
        Task {
            await load()
        }
    }
    
    private func load() async {
        bookmarks = await bookmarkStore.load() ?? []
    }
    
    func isBookmarked(for media: Media) -> Bool {
        bookmarks.first { media.url == $0.url } != nil
    }
    
    func addBookmark(for media: Media) {
        guard !isBookmarked(for: media) else {
            return
        }
        
        bookmarks.insert(media, at: 0)
        bookmarkUpdated()
    }
    
    func removeBookmark(for media: Media) {
        guard let index = bookmarks.firstIndex(where: { $0.url == media.url }) else {
            return
        }
        bookmarks.remove(at: index)
        bookmarkUpdated()
    }
    
    func removeAllBookmarks() {
        bookmarks.removeAll()
        bookmarkUpdated()
    }
    
    func toggleBookmark(for media: Media) {
        if isBookmarked(for: media) {
            removeBookmark(for: media)
        } else {
            addBookmark(for: media)
        }
    }
    
    func bookMarkTitle(for media: Media) -> LocalizedStringKey {
        if isBookmarked(for: media) {
            return "Remove from Bookmark"
        } else {
            return "Add to Bookmark"
        }
    }
    
    func bookMarkIcon(for media: Media) -> String {
        if isBookmarked(for: media) {
            return "bookmark.fill"
        } else {
            return "bookmark"
        }
    }
    
    private func bookmarkUpdated() {
        let bookmarks = self.bookmarks
        Task {
            await bookmarkStore.save(bookmarks)
        }
    }
}
