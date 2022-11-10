//
//  CategoryMedias.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import Foundation

struct CategoryMedias: Codable {
    
    let category: Category
    let articles: [Media]
}
