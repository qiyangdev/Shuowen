//
//  SWEntryStore.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import Foundation
import SwiftData

@MainActor
struct SWEntryStore {
    let context: ModelContext

    func entryCount() throws -> Int {
        try context.fetchCount(FetchDescriptor<Entry>())
    }

    func entry(id: Int) throws -> Entry? {
        var descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { $0.entryID == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func randomEntry(excludingEntryID: Int? = nil) throws -> Entry? {
        func makeDescriptor(excludingID: Int?) -> FetchDescriptor<Entry> {
            if let excludingID {
                return FetchDescriptor(
                    predicate: #Predicate { $0.entryID != excludingID },
                    sortBy: [SortDescriptor(\.entryID)]
                )
            }
            return FetchDescriptor(sortBy: [SortDescriptor(\.entryID)])
        }

        var descriptor = makeDescriptor(excludingID: excludingEntryID)
        var count = try context.fetchCount(descriptor)
        if count == 0, excludingEntryID != nil {
            descriptor = makeDescriptor(excludingID: nil)
            count = try context.fetchCount(descriptor)
        }
        guard count > 0 else { return nil }

        descriptor.fetchOffset = Int.random(in: 0..<count)
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    func search(term: String) throws -> [Entry] {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        if SWPinyinNormalizer.isPinyinQuery(trimmed) {
            return try searchPinyin(trimmed)
        }
        return try searchHanzi(trimmed)
    }

    func searchExplanation(containing text: String, limit: Int = 50) throws -> [Entry] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate { $0.explanation.localizedStandardContains(trimmed) },
            sortBy: [SortDescriptor(\.entryID)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func entries(volume: String) throws -> [Entry] {
        try fetchEntries(where: #Predicate { $0.volume == volume })
    }

    func entries(radical: String) throws -> [Entry] {
        try fetchEntries(where: #Predicate { $0.radical == radical })
    }

    private func searchHanzi(_ term: String) throws -> [Entry] {
        var seen = Set<Int>()
        var results: [Entry] = []

        func merge(_ entries: [Entry]) {
            for entry in entries where seen.insert(entry.entryID).inserted {
                results.append(entry)
            }
        }

        merge(try fetchEntries(where: #Predicate { $0.wordhead == term }))
        merge(try fetchEntries(where: #Predicate { $0.radical == term }))

        // SwiftData crashes on `[String].contains` inside #Predicate — filter in memory.
        let indexMatches = try fetchAllEntries().filter { $0.indexes.contains(term) }
        merge(indexMatches)

        return sortHanziResults(results, term: term)
    }

    private func sortHanziResults(_ results: [Entry], term: String) -> [Entry] {
        let exact = results.filter { $0.wordhead == term }
        let indexMatches = results.filter { $0.wordhead != term && $0.indexes.contains(term) }
        let radicalMatches = results.filter {
            $0.wordhead != term && !$0.indexes.contains(term) && $0.radical == term
        }
        return exact + indexMatches + radicalMatches
    }

    private func searchPinyin(_ term: String) throws -> [Entry] {
        let normalized = SWPinyinNormalizer.normalize(term)

        var results = try fetchEntries(where: #Predicate { entry in
            entry.pinyin.localizedStandardContains(normalized)
                || entry.pinyinFull.localizedStandardContains(normalized)
        })

        if results.isEmpty {
            results = try matchPinyinWithToneNormalization(normalized)
        }
        return results
    }

    private func matchPinyinWithToneNormalization(_ normalizedPinyin: String) throws -> [Entry] {
        let firstLetter = String(normalizedPinyin.prefix(1))
        guard !firstLetter.isEmpty else { return [] }

        let candidates = try fetchEntries(where: #Predicate { entry in
            entry.pinyin.localizedStandardContains(firstLetter)
                || entry.pinyinFull.localizedStandardContains(firstLetter)
        })

        return candidates.filter { entry in
            SWPinyinNormalizer.normalize(entry.pinyin).contains(normalizedPinyin)
                || SWPinyinNormalizer.normalize(entry.pinyinFull).contains(normalizedPinyin)
                || SWPinyinNormalizer.normalize(entry.pinyin).hasPrefix(normalizedPinyin)
                || SWPinyinNormalizer.normalize(entry.pinyinFull).hasPrefix(normalizedPinyin)
        }
    }

    private func fetchEntries(
        where predicate: Predicate<Entry>,
        limit: Int? = nil
    ) throws -> [Entry] {
        var descriptor = FetchDescriptor<Entry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.entryID)]
        )
        if let limit {
            descriptor.fetchLimit = limit
        }
        return try context.fetch(descriptor)
    }

    private func fetchAllEntries() throws -> [Entry] {
        let descriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.entryID)])
        return try context.fetch(descriptor)
    }
}
