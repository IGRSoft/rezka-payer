//
//  DataStore.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import Foundation

protocol DataStore: Actor {
    
    associatedtype D
    
    func save(_ current: D)
    func load() -> D?
}

actor PlistDataStore<T: Codable>: DataStore where T: Equatable {
    
    private var saved: T?
    let filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    private var documentsURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    private var dataURL: URL {
        documentsURL.appendingPathComponent("\(filename).plist")
    }
    
    func save(_ current: T) {
        if let saved = self.saved, saved == current {
            return
        }
        
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            let data = try encoder.encode(current)
            try data.write(to: dataURL, options: [.atomic])
            self.saved = current
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func load() -> T? {
        do {
            let data = try Data(contentsOf: dataURL)
            let decoder = PropertyListDecoder()
            let current = try decoder.decode(T.self, from: data)
            self.saved = current
            return current
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
