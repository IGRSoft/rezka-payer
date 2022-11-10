//
//  CaseIterable+Index.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 23.10.2022.
//

import Foundation

extension CaseIterable where Self: Equatable {

    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}
