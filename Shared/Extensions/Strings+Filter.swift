//
//  Strings+Filter.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.10.2022.
//

import Foundation

extension String {
    var digits: String {
        return components(separatedBy: .decimalDigits.inverted).joined()
    }
    
    var letters: String {
        return components(separatedBy: .letters.inverted).joined()
    }
}
