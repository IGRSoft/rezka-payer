//
//  String+Propaganda.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 10.09.2024.
//  Copyright © 2024 IGR Soft. All rights reserved.
//

extension String {
    func isPropaganda() -> Bool {
        lowercased().contains("россия") || lowercased().contains("ссср")
    }
}
