//
//  StoreBuildRunner.swift
//  Shuowen
//

#if DEBUG
import Foundation
import SwiftData

#if os(macOS)
import AppKit
#endif

enum StoreBuildRunner {
    @MainActor
    static func run(container: ModelContainer) async {
        do {
            guard let directory = SWDataStore.launchImportDirectory else {
                throw SWJSONDecoderError.fileNotFound("--import directory")
            }

            SWStoreBuildLogger.log("Import from: \(directory.path)")

            let summary = try await SWEntryImporter.importFromDirectory(
                at: directory,
                container: container
            ) { savedCount, total in
                SWStoreBuildLogger.log("Saved \(savedCount) / \(total) entries")
                StoreBuildState.shared.update(saved: savedCount, total: total)
            }

            SWStoreBuildLogger.log(
                "Import complete: \(summary.entryCount) entries, id \(summary.minEntryID)-\(summary.maxEntryID)."
            )

            let sourceURL = try SWDataStore.applicationSupportStoreURL
            SWStoreBuildLogger.log("Source store: \(sourceURL.path)")
            SWStoreBuildLogger.log("Done.")
            StoreBuildState.shared.markFinished(outputPath: sourceURL.path)
        } catch {
            SWStoreBuildLogger.log("Import failed: \(error)")
            StoreBuildState.shared.markFailed(error.localizedDescription)
        }
    }

    static func quitIfNeeded() {
        guard SWDataStore.shouldQuitAfterImport else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            #if os(macOS)
            NSApplication.shared.terminate(nil)
            #else
            exit(0)
            #endif
        }
    }
}
#endif
