//
//  SWFavoriteStore.swift
//  Shuowen
//

import Foundation
import SwiftData

@MainActor
struct SWFavoriteStore {
    let context: ModelContext

    func isFavorite(entryID: Int) throws -> Bool {
        var descriptor = FetchDescriptor<FavoriteEntry>(
            predicate: #Predicate { $0.entryID == entryID }
        )
        descriptor.fetchLimit = 1
        return try !context.fetch(descriptor).isEmpty
    }

    func toggle(entryID: Int) throws -> Bool {
        if try isFavorite(entryID: entryID) {
            try remove(entryID: entryID)
            return false
        }
        context.insert(FavoriteEntry(entryID: entryID))
        try context.save()
        return true
    }

    func remove(entryID: Int) throws {
        let descriptor = FetchDescriptor<FavoriteEntry>(
            predicate: #Predicate { $0.entryID == entryID }
        )
        for favorite in try context.fetch(descriptor) {
            context.delete(favorite)
        }
        try context.save()
    }

    func favoriteEntryIDs() throws -> [Int] {
        let descriptor = FetchDescriptor<FavoriteEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map(\.entryID)
    }

    func favoriteEntries() throws -> [Entry] {
        let entryStore = SWEntryStore(context: context)
        return try favoriteEntryIDs().compactMap { try entryStore.entry(id: $0) }
    }
}
