//
//  MediaContentView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 16.08.2022.
//

import SwiftUI

struct MediaContentView: View {
    @EnvironmentObject var viewModel: MediaContentViewModel
    
    @StateObject private var bookmarkViewModel = MediaBookmarksViewModel.shared
    
#if os(tvOS)
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
#else
    private let columns = [
        GridItem(.flexible())
    ]
#endif
    
    var body: some View {
        VStack {
            ScrollView {
#if os(tvOS)
                if let elements = viewModel.subCategories {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(elements) { element in
                                Button(action: {
                                    Task {
                                        await viewModel.setSubCategory(element)
                                    }
                                }, label: {
                                    VStack {
                                        Label(element.name, systemImage: element != viewModel.selectedSubCategory ? "circle" : "circle.inset.filled")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.secondary, .blue)
                                    }
                                })
                            }
                        }
                        .padding(.init(top: 8, leading: 32, bottom: 32, trailing: 32))
                    }
                }
#endif
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
                            
                            Button (role: .cancel) {
                            } label: {
                                Text("Cancel")
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
            await viewModel.loadMedias()
        }
    }
    
    private func loadMoreTask() {
        Task {
            await viewModel.loadMore()
        }
    }
}

struct MediaNewContentView_Previews: PreviewProvider {
    static var previews: some View {
        MediaContentView()
            .environmentObject(MediaContentViewModel())
    }
}
