//
//  DataStore.swift
//  rezka-player
//
//  Created by Vitalii Parovishnyk on 18.08.2022.
//

import Foundation
import CloudKit

protocol DataStore: Actor {
    
    associatedtype D
    
    /// Saves object to store.
    /// - Parameter current: Object to save.
    func save(_ current: D) async throws

    /// Loads object from store.
    /// - Returns: Saved object or nil.
    func load() async throws -> D?
}

actor CloudKitDataStore<T: Codable & Equatable>: DataStore {
    
    /// CloudKit container for data operations.
    private let container: CKContainer

    /// CloudKit database for record storage.
    private let database: CKDatabase

    /// Type name for CKRecord storage.
    private let recordType: String

    /// Identifier for the CloudKit record.
    private let recordID: CKRecord.ID

    /**
     Initializes data store for CloudKit operations.
     - Parameters:
       - containerIdentifier: Container identifier for CloudKit.
       - databaseScope: Database scope for CloudKit (default .private).
       - recordType: Type name for CKRecord.
       - recordName: Unique record name.
     */
    init(containerIdentifier: String = ConstantsApi.iCloudKey,
         databaseScope: CKDatabase.Scope = .private,
         recordType: String,
         recordName: String) {
        self.container = CKContainer(identifier: containerIdentifier)
        self.database = container.database(with: databaseScope)
        self.recordType = recordType
        self.recordID = CKRecord.ID(recordName: recordName)
    }

    /**
     Saves object to CloudKit record.
     - Parameter current: Object to save.
     */
    func save(_ current: T) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(current)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        record["data"] = data
        
        do {
            try await database.deleteRecord(withID: recordID)
            _ = try await database.save(record)
        } catch {
            print(error.localizedDescription)
        }
    }

    /**
     Loads object from CloudKit record.
     - Returns: Decoded object or nil if absent.
     */
    func load() async throws -> T? {
        let record = try await database.record(for: recordID)
        guard let data = record["data"] as? Data else {
            return nil
        }
        let decoder = JSONDecoder()
        let current = try decoder.decode(T.self, from: data)
        return current
    }
}
