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
            VStack(alignment: .leading, spacing: 24) {
                ZStack(alignment: .topTrailing) {
                    ZStack (alignment: .bottomLeading) {
                        CacheAsyncImage(url: media.coverURL) { phase in
                            phase.view
                        }
                        .frame(width: proxy.size.width, height: MediaItemViewView.coverSize.height * 0.73)
                        .padding(.init(top: 16, leading: 0, bottom: 0, trailing: 0))
                        if media.isSeries, let seriesInfo = media.seriesInfo {
                            Text(seriesInfo)
                                .font(.caption)
                                .foregroundColor(.black)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .background(.primary)
                                .cornerRadius(8)
                        }
                    }
                    HStack(spacing: 16) {
                        Text(media.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 8))
                        
                        media.category.icon
                            .frame(width: 14, height: 14)
                            .foregroundStyle(.primary)
                            .padding(.init(top: 8, leading: 0, bottom: 8, trailing: 24))
                    }
                    .background(media.category.color)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    
                    Text(media.title)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(nil)
                        .frame(height: 78, alignment: .top)
                    
                    Spacer(minLength: 6)
                    
                    HStack {
                        Text(media.descriptionShort)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        
                        if bookmarkViewModel.isBookmarked(for: media) {
                            Spacer()
                            Image(systemName: "bookmark.fill")
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
    }
}

struct MediaItemViewView_Previews: PreviewProvider {
    static var previews: some View {
        MediaItemViewView(media: Media.previewData.first!, bookmarkViewModel: MediaBookmarksViewModel.shared)
    }
}
