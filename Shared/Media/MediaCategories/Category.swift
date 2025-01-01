//
//  Category.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import SwiftUI

enum Category: String, CaseIterable, Codable {
    case none
    case general
    case search
    case new
    case films
    case series
    case cartoons
    case animation
    case announce
    case collections
    case loadMore
    
    var text: String {
        if self == .general {
            return "Top Headlines"
        }
        return rawValue.capitalized
    }
    
    var icon: Image {
        switch self {
        case .general: Image(systemName: "video.fill")
        case .films: Image(systemName: "video.fill")
        case .series: Image(systemName: "play.square.stack")
        case .cartoons: Image(systemName: "ticket")
        case .animation: Image(systemName: "paintbrush.pointed")
        case .search: Image(systemName: "magnifyingglass")
        case .new: Image(systemName: "magnifyingglass")
        case .none: Image(systemName: "magnifyingglass")
        case .announce: Image(systemName: "magnifyingglass")
        case .collections: Image(systemName: "magnifyingglass")
        case .loadMore: Image(systemName: "circle.dashed")
        }
    }
    
    var color: Color {
        switch self {
        case .general: Color("CategoryGeneralColor")
        case .films: Color("CategoryFilmColor")
        case .series: Color("CategorySeriesColor")
        case .cartoons: Color("CategoryCartoonsColor")
        case .animation: Color("CategoryAnimationColor")
        case .search: Color("CategoryGeneralColor")
        case .new: Color("CategoryGeneralColor")
        case .none: Color("CategoryGeneralColor")
        case .announce: Color("CategoryGeneralColor")
        case .collections: Color("CategoryGeneralColor")
        case .loadMore: Color("CategoryGeneralColor")
        }
    }
    
    var sortIndex: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

extension Category: Identifiable {
    var id: Self { self }
}
