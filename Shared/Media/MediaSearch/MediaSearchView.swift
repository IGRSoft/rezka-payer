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
            SearchBarView(text: $text) {
                MediaSearchContentView()
                    .environmentObject(viewModel)
                    .onChange(of: text) { newValue in
                        Task {
                            await viewModel.updateSearch(text: text)
                        }
                    }
            }
        }
    }
}

struct MediaSearchContentView: View {
    @EnvironmentObject var viewModel: MediaSearchContentViewModel
    
    @StateObject private var bookmarkViewModel = MediaBookmarksViewModel.shared
    
    @State private var scrollViewHeight = CGFloat.infinity
    @Namespace private var scrollViewNameSpace
    
    @State private var isLoading = true
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            NavigationView {
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
                    }
                    .padding()
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(of: proxy.frame(in: .named(scrollViewNameSpace))) { newFrame in
                                    if newFrame.size.height + newFrame.minY <= scrollViewHeight {
                                        loadMoreTask()
                                    }
                                }
                        }
                    )
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size, perform: { newSize in
                                scrollViewHeight = newSize.height
                            })
                    }
                )
                .coordinateSpace(name: scrollViewNameSpace)
            }
            .overlay(overlayView)
            .task {
                refreshTask()
            }
#if os(macOS)
            .frame(maxWidth: 1024, maxHeight: 1024)
#endif
        }
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
