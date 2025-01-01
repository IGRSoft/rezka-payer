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
        VStack(spacing: .zero) {
            ScrollView {
#if os(tvOS)
                if let elements = viewModel.subCategories {
                    ScrollView(.horizontal) {
                        HStack(spacing: 24) {
                            ForEach(elements) { element in
                                Button(action: {
                                    Task {
                                        await viewModel.setSubCategory(element)
                                    }
                                }, label: {
                                    Label(element.name, systemImage: element != viewModel.selectedSubCategory ? "circle" : "circle.inset.filled")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.secondary, .blue)
                                })
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 4)
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
                        .buttonStyle(MediaButtonStyle())
                        .modifier(FocusMediaAnimationModifier())
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
                        .onAppear() {
                            if media.category == .loadMore {
                                loadMoreTask()
                            }
                        }
                    }
                }
                .padding(.top, 16)
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
            await viewModel.loadMedias()
        }
    }
    
    private func loadMoreTask() {
        Task {
            await viewModel.loadMore()
        }
    }
}

struct FocusMediaAnimationModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
        .padding(5)
        .border(.blue, width: isFocused ? 10 : 0)
        .cornerRadius(10)
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isFocused)
        .focused($isFocused)
    }
}

struct MediaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10)
                .fill(Color("MediaTileBackgroundColor"))
            )
    }
}

struct MediaNewContentView_Previews: PreviewProvider {
    static var previews: some View {
        MediaContentView()
            .environmentObject(MediaContentViewModel())
    }
}
