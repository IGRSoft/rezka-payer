//
//  MediaItemDetailsView.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 12.10.2022.
//

import SwiftUI

struct DetailedMediaItemView: View {
#if os(iOS)
    static let coverSize = CGSize(width: 200, height: 300)
#elseif os(macOS)
    static let coverSize = CGSize(width: 300, height: 500)
#else
    static let coverSize = CGSize(width: 400, height: 600)
#endif
    
    @StateObject var viewModel: DetailedMediaItemViewModel
    
    @StateObject var bookmarkViewModel: MediaBookmarksViewModel
    
    @State private var isTranslationMenuPresented = false
    @State private var isSeasonsMenuPresented = false
    @State private var isEpisodesMenuPresented = false
    @State private var isQualityMenuPresented = false
    @State private var isPlayerPresented = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.title)
                .foregroundStyle(.primary)
                .padding(.bottom)
            
            Text(viewModel.originalTitle)
                .font(.subheadline)
                .padding(.bottom)
            
            detailView
                .task {
                    refreshTask()
                }
        }
        .overlay(overlayView)
    }
    
    private var detailView: some View {
        VStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        HStack(alignment: .top) {
                            if let coverUrl = viewModel.coverUrl {
                                VStack {
                                    NavigationLink {
                                        ImagePreview(url: coverUrl)
                                    } label: {
                                        CacheAsyncImage(url: coverUrl) { phase in
                                            phase.view
                                        }
                                        .frame(width: DetailedMediaItemView.coverSize.width, height: DetailedMediaItemView.coverSize.height)
                                        .clipped()
                                        .padding(.init(top: 16, leading: 0, bottom: 0, trailing: 0))
                                    }
                                    
                                    Button {
                                        bookmarkViewModel.toggleBookmark(for: viewModel.media)
                                    } label: {
                                        Label(bookmarkViewModel.bookMarkTitle(for: viewModel.media), systemImage: bookmarkViewModel.bookMarkIcon(for: viewModel.media))
                                    }
                                }
                            }
                            Spacer()
                            viewModel.info.grid
                        }
                        
                        VStack(alignment: .leading, spacing: 32) {
                            Text(viewModel.description)
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack {
                                if let title = viewModel.currentTranslationTitle {
#if os(tvOS)
                                    Button {
                                        isTranslationMenuPresented.toggle()
                                    } label: {
                                        Text(title)
                                    }
#else
                                    Menu {
                                        translationMenu
                                    } label: {
                                        Text(title)
                                    }
#endif
                                    if let seasons = viewModel.seasonsInCurrentTranslation, seasons.isEmpty == false, let currentSeason = viewModel.currentSeasonTitle , let currentEpisodeTitle = viewModel.currentEpisodeTitle {
#if os(tvOS)
                                        Button {
                                            isSeasonsMenuPresented.toggle()
                                        } label: {
                                            Text(currentSeason)
                                        }
                                        
                                        Button {
                                            isEpisodesMenuPresented.toggle()
                                        } label: {
                                            Text(currentEpisodeTitle)
                                        }
#else
                                        Menu {
                                            translationMenu
                                        } label: {
                                            Text(currentSeason)
                                        }
                                        
                                        Menu {
                                            episodesMenu
                                        } label: {
                                            Text(currentEpisodeTitle)
                                        }
#endif
                                    }
                                    Button(role: .destructive) {
                                        isPlayerPresented = true
                                    } label: {
                                        Image(systemName: "play.circle")
                                    }
                                    
                                    if let _ = viewModel.streams?.qualities {
#if os(tvOS)
                                        Button {
                                            isQualityMenuPresented.toggle()
                                        } label: {
                                            Text(viewModel.currentQuality.rawValue)
                                        }
#else
                                        Menu {
                                            qualitiesMenu
                                        } label: {
                                            Text(viewModel.currentQuality.rawValue)
                                        }
#endif
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
#if os(tvOS) || os(iOS)
        .fullScreenCover(isPresented: $isTranslationMenuPresented) {
            MenuView(items: AnyView(translationMenu))
        }
        .fullScreenCover(isPresented: $isSeasonsMenuPresented) {
            MenuView(items: AnyView(seasonsMenu))
        }
        .fullScreenCover(isPresented: $isEpisodesMenuPresented) {
            MenuView(items: AnyView(episodesMenu))
        }
        .fullScreenCover(isPresented: $isQualityMenuPresented) {
            MenuView(items: AnyView(qualitiesMenu))
        }
        .fullScreenCover(isPresented: $isPlayerPresented, content: {
            PlayerViewController(videoURL: URL(string: viewModel.stream))
                .edgesIgnoringSafeArea(.all)
                .transition(.move(edge: .bottom))
            
        })
#endif
    }
    
    private func selectTranslation(id: Int) async {
        try? await viewModel.setCurrentTranslation(id: id)
        isTranslationMenuPresented.toggle()
    }
    
    private func selectSeason(id: Int) async {
        try? await viewModel.setCurrentSeason(id: id)
        isSeasonsMenuPresented.toggle()
    }
    
    private func selectEpisode(id: Int) async {
        try? await viewModel.setCurrentEpisode(id: id)
        isEpisodesMenuPresented.toggle()
    }
    
    private func selectQuality(id: Media.Quality) async {
        viewModel.setQuality(id)
        isQualityMenuPresented.toggle()
    }
    
    @ViewBuilder
    private var translationMenu: some View {
        let items = viewModel.translations
        ForEach(Array(zip(items.values.indices, items)), id: \.0) { _, translation in
            Button {
                Task {
                    await selectTranslation(id: translation.key)
                }
            } label: {
                Text(translation.value)
            }
        }
    }
    
    @ViewBuilder
    private var seasonsMenu: some View {
        if let seasons = viewModel.seasonsInCurrentTranslation {
            let items = seasons.keys.compactMap({ Int($0) })
            ForEach(items, id: \.self) { item in
                Button {
                    Task {
                        await selectSeason(id: item)
                    }
                } label: {
                    if let name = seasons[item] {
                        Text(name)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var episodesMenu: some View {
        if let episodes = viewModel.episodes {
            let items = episodes.map({ $0.id })
            ForEach(items, id: \.self) { episodeId in
                Button {
                    Task {
                        await selectEpisode(id: episodeId)
                    }
                } label: {
                    if let episode = episodes.first(where: { $0.id == episodeId }) {
                        Text(episode.title)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var qualitiesMenu: some View {
        if let qualities = viewModel.streams?.qualities {
            let items = qualities.map({ $0.rawValue })
            ForEach(items, id: \.self) { quality in
                Button {
                    Task {
                        await selectQuality(id: Media.Quality(rawValue: quality) ?? .unknown)
                    }
                } label: {
                    Text(quality)
                }
            }
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .fetching:
            ProgressView()
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: refreshTask)
            
        default: EmptyView()
        }
    }
    
    private func refreshTask() {
        Task {
            await viewModel.loadDetailedMedia()
        }
    }
}

struct DetailedMediaItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailedMediaItemView(viewModel: DetailedMediaItemViewModel(media: Media.previewData[1]), bookmarkViewModel: MediaBookmarksViewModel.shared)
        }
    }
}
