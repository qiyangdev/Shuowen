//
//  StoreBuildState.swift
//  Shuowen
//

#if DEBUG
import Foundation
import Observation

@Observable
@MainActor
final class StoreBuildState {
    static let shared = StoreBuildState()

    var processed = 0
    var total = 0
    var message = String(localized: "Preparing…")
    var isFinished = false
    var errorMessage: String?

    private init() {}

    func update(saved: Int, total: Int) {
        processed = saved
        self.total = total
        message = "Saved \(saved) / \(total) entries"
    }

    func markFinished(outputPath: String) {
        isFinished = true
        message = outputPath
    }

    func markFailed(_ error: String) {
        errorMessage = error
        message = String(localized: "Import failed")
    }
}
#endif
