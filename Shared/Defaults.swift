//
//  Defaults.swift
//  rezka-player
//
//  Created by Andrii Tishchenko on 26.02.2024.
//  Copyright © 2024 IGR Soft. All rights reserved.
//

import Foundation

fileprivate let quality_key   = "quality.key"
fileprivate let translate_key = "translate.key"


extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.rezka-player")
    
    var quality : Media.Quality {
        set(val){
            UserDefaults.group?.set(val.rawValue, forKey: quality_key)
        }
        get{
            guard let val = UserDefaults.group?.string(forKey: quality_key) else {
                return Media.Quality.unknown
            }
            return Media.Quality(rawValue: val)!
        }
    }
    
    var translate : Int? {
        set(val){
            UserDefaults.group?.set(val, forKey: translate_key)
        }
        get{
            guard let val = UserDefaults.group?.integer(forKey: translate_key) else {
                return nil
            }
            return val
        }
    }
    
}
