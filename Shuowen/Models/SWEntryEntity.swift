//
//  SWEntryEntity.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import Foundation
import SwiftData

@Model
final class Entry {
    var entryID: Int = 0
    var wordhead: String = ""
    var explanation: String = ""
    var volume: String = ""
    var radical: String = ""
    var pronunciation: String = ""
    var sealCharacter: String = ""
    var pinyin: String = ""
    var pinyinFull: String = ""
    var xuanNote: String = ""
    var kaiNote: String = ""
    var components: [String] = []
    var indexes: [String] = []

    @Relationship(deleteRule: .cascade, inverse: \Variant.entry)
    var variants: [Variant] = []

    @Relationship(deleteRule: .cascade, inverse: \DuanNote.entry)
    var duanNotes: [DuanNote] = []

    init() {}

    static func make(from dto: SWEntry) -> Entry {
        let entry = Entry()
        entry.entryID = dto.id
        entry.wordhead = dto.wordhead
        entry.explanation = dto.explanation
        entry.volume = dto.volume
        entry.radical = dto.radical
        entry.pronunciation = dto.pronunciation
        entry.sealCharacter = dto.sealCharacter
        entry.pinyin = dto.pinyin
        entry.pinyinFull = dto.pinyinFull
        entry.xuanNote = dto.xuanNote
        entry.kaiNote = dto.kaiNote
        entry.components = dto.components
        entry.indexes = dto.indexes
        entry.variants = dto.variants.map { variantDTO in
            let variant = Variant.make(from: variantDTO)
            variant.entry = entry
            return variant
        }
        entry.duanNotes = dto.duanNotes.map { noteDTO in
            let note = DuanNote.make(from: noteDTO)
            note.entry = entry
            return note
        }
        return entry
    }
}

@Model
final class Variant {
    var wordhead: String = ""
    var explanation: String = ""
    var sealCharacter: String = ""
    var entry: Entry?

    init() {}

    static func make(from dto: SWVariant) -> Variant {
        let variant = Variant()
        variant.wordhead = dto.wordhead
        variant.explanation = dto.explanation
        variant.sealCharacter = dto.sealCharacter
        return variant
    }
}

@Model
final class DuanNote {
    var explanation: String = ""
    var note: String = ""
    var entry: Entry?

    init() {}

    static func make(from dto: SWDuanNote) -> DuanNote {
        let duanNote = DuanNote()
        duanNote.explanation = dto.explanation
        duanNote.note = dto.note
        return duanNote
    }
}
