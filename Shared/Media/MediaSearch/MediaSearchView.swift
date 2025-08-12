//
//  MediaSearchView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 16.08.2022.
//

import SwiftUI

struct MediaSearchView: View {
    @State private var text: String = ""
    
    @StateObject private var viewModel = MediaSearchContentViewModel(search: "")
    
    var body: some View {
#if !os(macOS)
        MediaSearchContentView()
            .environmentObject(viewModel)
            .onChange(of: text) { _, newValue in
                Task {
                    await viewModel.updateSearch(text: newValue)
                }
            }
            .searchable(text: $text)
#endif
    }
}

struct MediaSearchContentView: View {
    @EnvironmentObject var viewModel: MediaSearchContentViewModel
    
    @StateObject private var bookmarkViewModel = MediaBookmarksViewModel.shared
    
    @State private var cardSize: CGSize = MediaItemViewView.coverSize
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(viewModel.newMedias) { media in
                        NavigationLink {
                            DetailedMediaItemView(viewModel: DetailedMediaItemViewModel(media: media), bookmarkViewModel: bookmarkViewModel)
                        } label: {
                            MediaItemViewView(media: media, bookmarkViewModel: bookmarkViewModel)
                                .frame(width: cardSize.width, height: cardSize.height)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
#if os(tvOS)
                        .buttonStyle(.card)
#else
                        .buttonStyle(.bordered)
#endif
                        .contextMenu {
                            Button {
                                bookmarkViewModel.toggleBookmark(for: media)
                            } label: {
                                Text(bookmarkViewModel.bookMarkTitle(for: media))
                            }
                        }
                    }
                    // latest empty label to fetch more data
                    Color.clear
                        .frame(height: 1)
                        .onAppear(perform: loadMoreTask)
                }
                .padding(.vertical, 24)
            }
        }
        .overlay(overlayView)
        .onFirstAppear(refreshTask)
#if os(macOS)
        .frame(maxWidth: 1024, maxHeight: 1024)
#endif
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .fetching:
            progress
        case .fetchingNextPage:
            progress
        case .success(let medias) where medias.isEmpty:
            EmptyPlaceholderView(text: "No Medias", image: nil)
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: refreshTask)
        default: EmptyView()
        }
    }
    
    @ViewBuilder
    private var progress: some View {
        ProgressView()
            .padding(32)
            .background(.white)
            .tint(.black)
            .cornerRadius(8)
            .scaleEffect(1.4)
    }
    
    private func refreshTask() {
        Task {
            await viewModel.searchMedias()
        }
    }
    
    private func loadMoreTask() {
        Task {
            await viewModel.loadMore()
        }
    }
}

struct MediaSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MediaSearchView()
    }
}
