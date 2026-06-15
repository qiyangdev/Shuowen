//
//  SWJSONDecoder.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import Foundation

enum SWJSONDecoderError: LocalizedError, Sendable {
    case fileNotFound(String)
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            "JSON file not found: \(name)"
        case .invalidFormat:
            "JSON must be a single entry object or an array of entries"
        }
    }
}

enum SWJSONDecoder: Sendable {
    /// Decodes a single entry from a local file URL.
    nonisolated static func decodeEntry(from url: URL) throws -> SWEntry {
        let data = try Data(contentsOf: url)
        return try decodeEntry(from: data)
    }

    /// Decodes a single entry from raw JSON data.
    nonisolated static func decodeEntry(from data: Data) throws -> SWEntry {
        try JSONDecoder().decode(SWEntry.self, from: data)
    }
}
