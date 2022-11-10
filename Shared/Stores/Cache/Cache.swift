//
//  Cache.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 21.08.2022.
//

import Foundation

protocol Cache: Actor {
    
    associatedtype V
    var expirationInterval: TimeInterval { get }
    
    func setValue(_ value: V?, forKey key: String)
    func value(forKey key: String) -> V?
    
    func removeValue(forKey key: String)
    func removeAllValues()
}
