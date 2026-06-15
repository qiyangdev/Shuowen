//
//  SWDataStore.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import Foundation
import SwiftData

enum SWDataStore {
    static let schema = Schema([
        Entry.self, Variant.self, DuanNote.self, FavoriteEntry.self,
    ])
    static let storeFileName = "shuowen.store"
    static let bundledStoreName = "shuowen"

    static var applicationSupportStoreURL: URL {
        get throws {
            let support = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let directory = support.appendingPathComponent(
                "Shuowen",
                isDirectory: true
            )
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            return directory.appendingPathComponent(storeFileName)
        }
    }

    static func makeContainer() throws -> ModelContainer {
        let storeURL = try applicationSupportStoreURL
        #if DEBUG
            if !isStoreBuildLaunch {
                try installBundledStoreIfNeeded(at: storeURL)
            }
        #else
            try installBundledStoreIfNeeded(at: storeURL)
        #endif

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static var hasBundledStore: Bool {
        Bundle.main.url(forResource: bundledStoreName, withExtension: "store")
            != nil
    }

    /// Copies a pre-built `shuowen.store` from the app bundle on first launch.
    private static func installBundledStoreIfNeeded(at destination: URL) throws
    {
        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: destination.path) else { return }

        guard
            let bundledStore = Bundle.main.url(
                forResource: bundledStoreName,
                withExtension: "store"
            )
        else {
            return
        }

        try fileManager.copyItem(at: bundledStore, to: destination)
    }

    #if DEBUG
        static var isStoreBuildLaunch: Bool {
            launchImportDirectory != nil
        }

        /// Launch argument for store building: `--import=/path/to/json/folder`
        static var launchImportDirectory: URL? {
            launchArgumentValue(prefix: "--import=").map {
                URL(fileURLWithPath: $0, isDirectory: true)
            }
        }

        /// Launch argument for store export: `--output=/path/to/shuowen.store`
        static var launchOutputURL: URL? {
            launchArgumentValue(prefix: "--output=").map {
                URL(fileURLWithPath: $0)
            }
        }

        /// Removes the local store so `--import` can rebuild from scratch.
        static func resetStoreForImport() throws {
            let storeURL = try applicationSupportStoreURL
            SWStoreCheckpoint.removeStoreFiles(at: storeURL)
        }

        static var shouldQuitAfterImport: Bool {
            ProcessInfo.processInfo.arguments.contains("--quit-after-import")
        }

        static var launchLogURL: URL? {
            launchArgumentValue(prefix: "--log=").map {
                URL(fileURLWithPath: $0)
            }
        }

        static var defaultExportURL: URL {
            #if os(macOS)
                return FileManager.default.homeDirectoryForCurrentUser
                    .appendingPathComponent("Desktop/\(storeFileName)")
            #else
                let documents = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]
                return documents.appendingPathComponent(storeFileName)
            #endif
        }

        static func exportStore(to destination: URL) throws {
            let sourceURL = try applicationSupportStoreURL
            let fileManager = FileManager.default

            guard fileManager.fileExists(atPath: sourceURL.path) else {
                throw SWJSONDecoderError.fileNotFound(sourceURL.path)
            }

            let parent = destination.deletingLastPathComponent()
            try fileManager.createDirectory(
                at: parent,
                withIntermediateDirectories: true
            )

            try SWStoreCheckpoint.backupStore(from: sourceURL, to: destination)
        }

        private static func launchArgumentValue(prefix: String) -> String? {
            for argument in ProcessInfo.processInfo.arguments
            where argument.hasPrefix(prefix) {
                return String(argument.dropFirst(prefix.count))
            }
            return nil
        }
    #endif
}
