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
        ZStack(alignment: .top) {
            ZStack(alignment: .topTrailing) {
                if let url = media.coverURL {
                    CacheAsyncImage(url: url) { $0.view }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                HStack(spacing: 16) {
                    Text(media.category.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .padding(.leading, 16)
                    
                    media.category.icon
                        .frame(width: 18, height: 18)
                        .padding(.trailing, 24)
                        .foregroundStyle(.primary)
                }
                .padding(8)
                .background(media.category.color.opacity(0.9))
                .clipShape(.rect(bottomLeadingRadius: 8))
            }
            
            ZStack(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    if media.isSeries, let seriesInfo = media.seriesInfo {
                        Text(seriesInfo)
                            .font(.subheadline)
                            .lineLimit(1)
                            .padding(16)
                            .foregroundStyle(.primary)
                            .colorInvert()
                            .background(Color("MediaTileSeriesBackgroundColor"))
                            .clipShape(.rect(bottomTrailingRadius: 8, topTrailingRadius: 8))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(media.title)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        
                        HStack {
                            Text(media.descriptionShort)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Image(systemName: "bookmark.fill")
                                .opacity(bookmarkViewModel.isBookmarked(for: media) ? 1 : 0.1)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .opacity(media.category == .loadMore ? 0.001 : 1)
    }
}

struct MediaItemViewView_Previews: PreviewProvider {
    static var previews: some View {
        MediaContentView()
            .environmentObject(MediaContentViewModel())
    }
}
