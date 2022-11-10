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
    
    var text: String {
        if self == .general {
            return "Top Headlines"
        }
        return rawValue.capitalized
    }
    
    var icon: Image {
        switch self {
        case .general:
            return Image(systemName: "video.fill")
        case .films:
            return Image(systemName: "video.fill")
        case .series:
            return Image(systemName: "play.rectangle.fill")
        case .cartoons:
            return Image(systemName: "ticket")
        case .animation:
            return Image(systemName: "paintbrush.pointed")
        case .search:
            return Image(systemName: "magnifyingglass")
        case .new:
            return Image(systemName: "magnifyingglass")
        case .none:
            return Image(systemName: "magnifyingglass")
        case .announce:
            return Image(systemName: "magnifyingglass")
        case .collections:
            return Image(systemName: "magnifyingglass")
        }
    }
    
    var color: Color {
        switch self {
        case .general:
            return Color("CategoryGeneralColor")
        case .films:
            return Color("CategoryFilmColor")
        case .series:
            return Color("CategorySeriesColor")
        case .cartoons:
            return Color("CategoryGeneralColor")
        case .animation:
            return Color("CategoryGeneralColor")
        case .search:
            return Color("CategoryGeneralColor")
        case .new:
            return Color("CategoryGeneralColor")
        case .none:
            return Color("CategoryGeneralColor")
        case .announce:
            return Color("CategoryGeneralColor")
        case .collections:
            return Color("CategoryGeneralColor")
        }
    }
    
    var sortIndex: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}

extension Category: Identifiable {
    var id: Self { self }
}
