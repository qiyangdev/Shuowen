//
//  SWPinyinNormalizer.swift
//  Shuowen
//

import Foundation

enum SWPinyinNormalizer {
    /// "yī" → "yi", "jiànɡ" → "jiang"
    static func normalize(_ text: String) -> String {
        let lowered = text.lowercased()
        let mapped = lowered.map { character -> Character in
            switch character {
            case "\u{0261}": "g" // LATIN SMALL LETTER SCRIPT G
            case "\u{0259}": "e" // schwa, occasionally appears in pinyin data
            default: character
            }
        }
        let ascii = String(mapped)
        return ascii.applyingTransform(.stripDiacritics, reverse: false) ?? ascii
    }

    /// Only ASCII letters/digits count as pinyin input. Chinese chars like "一" are not pinyin.
    static func isPinyinQuery(_ text: String) -> Bool {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return false }
        return normalized.unicodeScalars.allSatisfy {
            Character($0).isASCII && (Character($0).isLetter || Character($0).isNumber)
        }
    }
}
