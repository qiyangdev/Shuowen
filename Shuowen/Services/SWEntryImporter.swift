//
//  SWEntryImporter.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//
//  DEBUG-only: builds `shuowen.store` from a local JSON folder via `--import=`.
//  See Scripts/import_entries.sh

#if DEBUG
    import Foundation
    import SwiftData

    enum SWEntryImporterError: LocalizedError {
        case duplicateEntryID(Int)
        case entryCountMismatch(expected: Int, actual: Int)
        case missingEntryIDs([Int])
        case batchSaveFailed(entryIDs: [Int], underlying: Error)
        case filenameIDMismatch(file: String, fileID: Int, jsonID: Int)

        var errorDescription: String? {
            switch self {
            case .duplicateEntryID(let id):
                return "Duplicate entry id in import batch: \(id)"
            case .entryCountMismatch(let expected, let actual):
                return
                    "Entry count mismatch after import: expected \(expected), got \(actual)"
            case .missingEntryIDs(let ids):
                let preview = ids.prefix(10).map(String.init).joined(
                    separator: ", "
                )
                let suffix = ids.count > 10 ? " … (\(ids.count) total)" : ""
                return "Missing entry ids after import: \(preview)\(suffix)"
            case .batchSaveFailed(let entryIDs, let underlying):
                let preview = entryIDs.prefix(5).map(String.init).joined(
                    separator: ", "
                )
                return
                    "Failed to save entries [\(preview)]: \(underlying.localizedDescription)"
            case .filenameIDMismatch(let file, let fileID, let jsonID):
                return
                    "\(file): filename id \(fileID) does not match json id \(jsonID)"
            }
        }
    }

    enum SWEntryImporter {
        static let batchSize = 50

        struct ImportSummary: Sendable {
            let fileCount: Int
            let entryCount: Int
            let minEntryID: Int
            let maxEntryID: Int
        }

        @MainActor
        static func importFromDirectory(
            at directoryURL: URL,
            container: ModelContainer,
            onProgress: (@MainActor (Int, Int) -> Void)? = nil
        ) async throws -> ImportSummary {
            let urls = try jsonFiles(in: directoryURL)
            guard !urls.isEmpty else {
                throw SWJSONDecoderError.fileNotFound(
                    "No .json files in: \(directoryURL.path)"
                )
            }

            let total = urls.count
            SWStoreBuildLogger.log("Found \(total) JSON files.")
            onProgress?(0, total)

            let context = ModelContext(container)
            context.autosaveEnabled = false

            var seenEntryIDs = Set<Int>()
            seenEntryIDs.reserveCapacity(total)

            for batchStart in stride(from: 0, to: total, by: batchSize) {
                let batchEnd = min(batchStart + batchSize, total)
                let batchURLs = Array(urls[batchStart..<batchEnd])

                SWStoreBuildLogger.log(
                    "Decoding ids \(batchStart + 1)-\(batchEnd) of \(total)…"
                )

                let dtos = try await Task.detached(priority: .userInitiated) {
                    try batchURLs.map { url in
                        try autoreleasepool {
                            try SWJSONDecoder.decodeEntry(from: url)
                        }
                    }
                }.value

                try validateBatch(
                    urls: batchURLs,
                    dtos: dtos,
                    seenEntryIDs: &seenEntryIDs
                )

                SWStoreBuildLogger.log(
                    "Saving ids \(dtos.first?.id ?? 0)-\(dtos.last?.id ?? 0)…"
                )
                try insertBatch(dtos, into: context)

                let savedCount = try fetchEntryCount(in: context)
                guard savedCount == seenEntryIDs.count else {
                    throw SWEntryImporterError.entryCountMismatch(
                        expected: seenEntryIDs.count,
                        actual: savedCount
                    )
                }

                onProgress?(savedCount, total)
            }

            let summary = try makeSummary(
                context: context,
                fileCount: total,
                seenEntryIDs: seenEntryIDs
            )
            SWStoreBuildLogger.log(
                "Validated \(summary.entryCount) entries (id \(summary.minEntryID)-\(summary.maxEntryID))."
            )

            try context.save()
            return summary
        }

        @MainActor
        private static func validateBatch(
            urls: [URL],
            dtos: [SWEntry],
            seenEntryIDs: inout Set<Int>
        ) throws {
            guard urls.count == dtos.count else {
                throw SWJSONDecoderError.invalidFormat
            }

            for (url, dto) in zip(urls, dtos) {
                if let fileID = Int(
                    url.deletingPathExtension().lastPathComponent
                ), fileID != dto.id {
                    throw SWEntryImporterError.filenameIDMismatch(
                        file: url.lastPathComponent,
                        fileID: fileID,
                        jsonID: dto.id
                    )
                }

                guard seenEntryIDs.insert(dto.id).inserted else {
                    throw SWEntryImporterError.duplicateEntryID(dto.id)
                }
            }
        }

        @MainActor
        private static func insertBatch(
            _ dtos: [SWEntry],
            into context: ModelContext
        ) throws {
            for dto in dtos {
                context.insert(Entry.make(from: dto))
            }

            do {
                try context.save()
            } catch {
                throw SWEntryImporterError.batchSaveFailed(
                    entryIDs: dtos.map(\.id),
                    underlying: error
                )
            }
        }

        @MainActor
        private static func makeSummary(
            context: ModelContext,
            fileCount: Int,
            seenEntryIDs: Set<Int>
        ) throws -> ImportSummary {
            let storedEntryCount = try fetchEntryCount(in: context)
            guard storedEntryCount == fileCount else {
                throw SWEntryImporterError.entryCountMismatch(
                    expected: fileCount,
                    actual: storedEntryCount
                )
            }
            guard storedEntryCount == seenEntryIDs.count else {
                throw SWEntryImporterError.entryCountMismatch(
                    expected: seenEntryIDs.count,
                    actual: storedEntryCount
                )
            }

            guard let minEntryID = seenEntryIDs.min(),
                let highestEntryID = seenEntryIDs.max()
            else {
                throw SWEntryImporterError.entryCountMismatch(
                    expected: fileCount,
                    actual: 0
                )
            }

            let expectedIDs = Set(minEntryID...highestEntryID)
            if expectedIDs.count == seenEntryIDs.count {
                let missing = expectedIDs.subtracting(seenEntryIDs).sorted()
                if !missing.isEmpty {
                    throw SWEntryImporterError.missingEntryIDs(missing)
                }
            }

            let storedMaxID = try fetchMaxEntryID(in: context)
            guard storedMaxID == highestEntryID else {
                throw SWEntryImporterError.entryCountMismatch(
                    expected: highestEntryID,
                    actual: storedMaxID
                )
            }

            return ImportSummary(
                fileCount: fileCount,
                entryCount: storedEntryCount,
                minEntryID: minEntryID,
                maxEntryID: highestEntryID
            )
        }

        @MainActor
        private static func fetchEntryCount(in context: ModelContext) throws
            -> Int
        {
            try context.fetchCount(FetchDescriptor<Entry>())
        }

        @MainActor
        private static func fetchMaxEntryID(in context: ModelContext) throws
            -> Int
        {
            var descriptor = FetchDescriptor<Entry>(
                sortBy: [SortDescriptor(\.entryID, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            return try context.fetch(descriptor).first?.entryID ?? 0
        }

        private static func jsonFiles(in directoryURL: URL) throws -> [URL] {
            let fileManager = FileManager.default
            var isDirectory: ObjCBool = false
            guard
                fileManager.fileExists(
                    atPath: directoryURL.path,
                    isDirectory: &isDirectory
                ),
                isDirectory.boolValue
            else {
                throw SWJSONDecoderError.fileNotFound(directoryURL.path)
            }

            let contents = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )

            return
                contents
                .filter { $0.pathExtension.lowercased() == "json" }
                .sorted { lhs, rhs in
                    let leftName = lhs.deletingPathExtension().lastPathComponent
                    let rightName = rhs.deletingPathExtension()
                        .lastPathComponent
                    let leftID = Int(leftName)
                    let rightID = Int(rightName)

                    switch (leftID, rightID) {
                    case (let left?, let right?):
                        if left != right { return left < right }
                    case (nil, _?):
                        return false
                    case (_?, nil):
                        return true
                    case (nil, nil):
                        break
                    }

                    return leftName.localizedStandardCompare(rightName)
                        == .orderedAscending
                }
        }
    }
#endif
