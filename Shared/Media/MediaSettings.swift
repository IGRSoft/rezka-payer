//
//  MediaSettings.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 12.08.2025.
//  Copyright © 2024 IGR Soft. All rights reserved.
//

import Foundation

struct MediaSettings: Codable, Equatable {
    
    var quality: Media.Quality = .p1080
    var translationId: Int = -1
}
