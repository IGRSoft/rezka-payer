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
        VStack {
#if !os(macOS)
            SearchBarView(text: $text) {
                MediaSearchContentView()
                    .environmentObject(viewModel)
                    .onChange(of: text) { newValue in
                        Task {
                            await viewModel.updateSearch(text: text)
                        }
                    }
            }
#endif
        }
    }
}

struct MediaSearchContentView: View {
    @EnvironmentObject var viewModel: MediaSearchContentViewModel
    
    @StateObject private var bookmarkViewModel = MediaBookmarksViewModel.shared
        
    private let columns = [
        GridItem(.flexible()),
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
                                .frame(width: MediaItemViewView.coverSize.width, height: MediaItemViewView.coverSize.height)
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
                    Label("", image: "")
                        .onAppear(perform: loadMoreTask)
                }
                .padding()
            }
        }
        .overlay(overlayView)
        .onFirstAppear {
            refreshTask()
            
        }
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
