//
//  MediaItemViewView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import SwiftUI

struct MediaItemViewView: View {
#if os(iOS)
    static let coverSize = CGSize(width: 200, height: 300)
#elseif os(macOS)
    static let coverSize = CGSize(width: 300, height: 500)
#else
    static let coverSize = CGSize(width: 400, height: 620)
#endif
    
    let media: Media
    @StateObject var bookmarkViewModel: MediaBookmarksViewModel
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ZStack(alignment: .topTrailing) {
                    ZStack (alignment: .bottomLeading) {
                        if let url = media.coverURL {
                            CacheAsyncImage(url: url) { $0.view }
                                .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height * 0.73)
                                .padding(.top, 16)
                        }
                        
                        if media.isSeries, let seriesInfo = media.seriesInfo {
                            Text(seriesInfo)
                                .font(.headline)
                                .lineLimit(1)
                                .padding(16)
                                .foregroundStyle(.primary)
                                .colorInvert()
                                .background(Color("MediaTileSeriesBackgroundColor"))
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Text(media.category.rawValue)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .padding(.leading, 16)
                        
                        media.category.icon
                            .frame(width: 18, height: 18)
                            .padding(.trailing, 24)
                            .foregroundStyle(.primary)
                    }
                    .padding(8)
                    .background(media.category.color)
                    .cornerRadius(8)
                }
                
                ZStack(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(media.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .frame(height: 92, alignment: .top)
                            
                            HStack {
                                Text(media.descriptionShort)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                Spacer()
                                
                                if bookmarkViewModel.isBookmarked(for: media) {
                                    
                                    Image(systemName: "bookmark.fill")
                                }
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(8)
                    }
                }
            }
            .opacity(media.category == .loadMore ? 0.001 : 1)
        }
    }
}

struct MediaItemViewView_Previews: PreviewProvider {
    static var previews: some View {
        MediaItemViewView(media: Media.previewData.first!, bookmarkViewModel: MediaBookmarksViewModel.shared)
    }
}
