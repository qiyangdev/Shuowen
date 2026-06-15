//
//  ShuowenTests.swift
//  ShuowenTests
//
//  Created by wangqiyang on 2026/6/12.
//

import Foundation
import SwiftData
import Testing
@testable import Shuowen

struct ShuowenTests {

    private var sampleJSONURL: URL {
        get throws {
            try #require(Bundle(for: BundleToken.self).url(forResource: "1", withExtension: "json"))
        }
    }

    private var sample9814JSONURL: URL {
        get throws {
            try #require(Bundle(for: BundleToken.self).url(forResource: "9814", withExtension: "json"))
        }
    }

    @Test func decodeSampleEntry() throws {
        let entry = try SWJSONDecoder.decodeEntry(from: sampleJSONURL)

        #expect(entry.id == 1)
        #expect(entry.wordhead == "一")
        #expect(entry.pinyinFull == "yī")
        #expect(entry.variants.count == 1)
        #expect(entry.variants[0].wordhead == "弌")
        #expect(entry.duanNotes.count == 3)
        #expect(entry.indexes == ["一", "弌"])
    }

    @Test func decodeEntry9814WithIndexForms() throws {
        let entry = try SWJSONDecoder.decodeEntry(from: sample9814JSONURL)

        #expect(entry.id == 9814)
        #expect(entry.wordhead == "𨡓")
        #expect(entry.pinyinFull == "jiànɡ")
        #expect(entry.variants.count == 2)
        #expect(entry.variants[0].sealCharacter == "祂")
        #expect(entry.indexes == ["𨡓", "𨟻", "𤖙", "醬", "酱"])
        #expect(SWPinyinNormalizer.normalize(entry.pinyinFull) == "jiang")
    }

    @Test @MainActor func importEntry9814IntoSwiftData() async throws {
        let container = try ModelContainer(
            for: Entry.self, Variant.self, DuanNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let dto = try SWJSONDecoder.decodeEntry(from: sample9814JSONURL)
        context.insert(Entry.make(from: dto))
        try context.save()

        let store = SWEntryStore(context: context)
        let entry = try #require(try store.entry(id: 9814))

        #expect(entry.indexes.contains("酱"))
        #expect(entry.variants.count == 2)
        #expect(try store.search(term: "酱").first?.entryID == 9814)
        #expect(try store.search(term: "jiang").first?.entryID == 9814)
    }

    @Test @MainActor func importEntryIntoSwiftData() async throws {
        let container = try ModelContainer(
            for: Entry.self, Variant.self, DuanNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let dto = try SWJSONDecoder.decodeEntry(from: sampleJSONURL)
        context.insert(Entry.make(from: dto))
        try context.save()

        let store = SWEntryStore(context: context)
        let entry = try #require(try store.entry(id: 1))

        #expect(entry.wordhead == "一")
        #expect(entry.variants.count == 1)
        #expect(entry.duanNotes.count == 3)
        #expect(try store.search(term: "弌").count == 1)
        #expect(try store.search(term: "yi").count == 1)
        #expect(try store.search(term: "yī").count == 1)
        #expect(try store.search(term: "一").first?.wordhead == "一")
        #expect(try store.entries(radical: "一").count >= 1)
    }

    @Test func roamDailyPickReusesEntryWithinSameDay() throws {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: SWRoamDailyPick.dateKey)
        defaults.removeObject(forKey: SWRoamDailyPick.entryIDKey)
        defer {
            defaults.removeObject(forKey: SWRoamDailyPick.dateKey)
            defaults.removeObject(forKey: SWRoamDailyPick.entryIDKey)
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let noon = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 6, day: 12, hour: 12))
        )

        let container = try ModelContainer(
            for: Entry.self, Variant.self, DuanNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let entry = Entry()
        entry.entryID = 42
        entry.wordhead = "水"
        context.insert(entry)
        try context.save()

        let store = SWEntryStore(context: context)

        defaults.set(SWRoamDailyPick.dayString(for: noon, calendar: calendar), forKey: SWRoamDailyPick.dateKey)
        defaults.set(42, forKey: SWRoamDailyPick.entryIDKey)

        let loaded = try SWRoamDailyPick.loadEntry(using: store, calendar: calendar, now: noon)
        #expect(loaded?.entryID == 42)
    }

    @Test @MainActor func randomEntryIncludesAllEntries() async throws {
        let container = try ModelContainer(
            for: Entry.self, Variant.self, DuanNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)

        let first = Entry()
        first.entryID = 37
        first.wordhead = "𥛱"

        let second = Entry()
        second.entryID = 48
        second.wordhead = "𥛽"

        let third = Entry()
        third.entryID = 1
        third.wordhead = "一"

        context.insert(first)
        context.insert(second)
        context.insert(third)
        try context.save()

        let store = SWEntryStore(context: context)
        let picked = try store.randomEntry()
        #expect([1, 37, 48].contains(picked?.entryID ?? -1))
    }

    @Test func normalizePinyin() {
        #expect(SWPinyinNormalizer.normalize("yī") == "yi")
        #expect(SWPinyinNormalizer.normalize("jiànɡ") == "jiang")
        #expect(SWPinyinNormalizer.normalize("Shi") == "shi")
        #expect(SWPinyinNormalizer.isPinyinQuery("yi"))
        #expect(SWPinyinNormalizer.isPinyinQuery("shi4"))
        #expect(!SWPinyinNormalizer.isPinyinQuery("一"))
        #expect(!SWPinyinNormalizer.isPinyinQuery("弌"))
    }

}

private final class BundleToken {}
