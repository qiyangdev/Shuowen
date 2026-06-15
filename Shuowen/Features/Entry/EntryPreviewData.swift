//
//  EntryPreviewData.swift
//  Shuowen
//

import Foundation
import SwiftData

enum EntryPreviewData {
    static var fixtureURL: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // Entry
            .deletingLastPathComponent() // Features
            .deletingLastPathComponent() // Shuowen
            .deletingLastPathComponent() // project root
            .appendingPathComponent("Scripts/entries/144.json")
    }

    static func makeEntry() throws -> Entry {
        let dto = try SWJSONDecoder.decodeEntry(from: fixtureURL)
        return Entry.make(from: dto)
    }
}
