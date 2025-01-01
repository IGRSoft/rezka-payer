//
//  DataFetchPhase.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.08.2022.
//

import Foundation

enum DataFetchPhase<T> {
    
    case fetching
    case success(T)
    case fetchingNextPage(T)
    case failure(Error)
    
    var value: T? {
        if case .success(let value) = self {
            value
        } else if case .fetchingNextPage(let value) = self {
            value
        } else {
            nil
        }
    }
}
