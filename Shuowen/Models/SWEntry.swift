//
//  SWEntry.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import Foundation

struct SWEntry: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let wordhead: String
    let explanation: String
    let volume: String
    let radical: String
    let pronunciation: String
    let variants: [SWVariant]
    let sealCharacter: String
    let pinyin: String
    let pinyinFull: String
    let components: [String]
    let xuanNote: String
    let kaiNote: String
    let duanNotes: [SWDuanNote]
    let indexes: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case wordhead
        case explanation
        case volume
        case radical
        case pronunciation
        case variants
        case sealCharacter = "seal_character"
        case pinyin
        case pinyinFull = "pinyin_full"
        case components
        case xuanNote = "xuan_note"
        case kaiNote = "kai_note"
        case duanNotes = "duan_notes"
        case indexes
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        wordhead = try container.decode(String.self, forKey: .wordhead)
        explanation = try container.decode(String.self, forKey: .explanation)
        volume = try container.decode(String.self, forKey: .volume)
        radical = try container.decode(String.self, forKey: .radical)
        pronunciation = try container.decode(
            String.self,
            forKey: .pronunciation
        )
        variants =
            try container.decodeIfPresent([SWVariant].self, forKey: .variants)
            ?? []
        sealCharacter =
            try container.decodeIfPresent(String.self, forKey: .sealCharacter)
            ?? ""
        pinyin =
            try container.decodeIfPresent(String.self, forKey: .pinyin) ?? ""
        pinyinFull =
            try container.decodeIfPresent(String.self, forKey: .pinyinFull)
            ?? ""
        components =
            try container.decodeIfPresent([String].self, forKey: .components)
            ?? []
        xuanNote =
            try container.decodeIfPresent(String.self, forKey: .xuanNote) ?? ""
        kaiNote =
            try container.decodeIfPresent(String.self, forKey: .kaiNote) ?? ""
        duanNotes =
            try container.decodeIfPresent([SWDuanNote].self, forKey: .duanNotes)
            ?? []
        indexes =
            try container.decodeIfPresent([String].self, forKey: .indexes) ?? []
    }
}

struct SWVariant: Decodable, Hashable, Sendable {
    let wordhead: String
    let explanation: String
    let sealCharacter: String

    enum CodingKeys: String, CodingKey {
        case wordhead
        case explanation
        case sealCharacter = "seal_character"
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        wordhead = try container.decode(String.self, forKey: .wordhead)
        explanation =
            try container.decodeIfPresent(String.self, forKey: .explanation)
            ?? ""
        sealCharacter =
            try container.decodeIfPresent(String.self, forKey: .sealCharacter)
            ?? ""
    }
}

struct SWDuanNote: Decodable, Hashable, Sendable {
    let explanation: String
    let note: String

    enum CodingKeys: String, CodingKey {
        case explanation
        case note
    }

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        explanation =
            try container.decodeIfPresent(String.self, forKey: .explanation)
            ?? ""
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
    }
}
