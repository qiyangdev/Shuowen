//
//  SWStoreCheckpoint.swift
//  Shuowen
//

#if DEBUG
import Foundation
import SQLite3

enum SWStoreCheckpointError: LocalizedError {
    case openFailed(String)
    case checkpointFailed(Int32)
    case backupFailed(Int32)
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let path):
            "Failed to open store: \(path)"
        case .checkpointFailed(let code):
            "SQLite WAL checkpoint failed with code \(code)"
        case .backupFailed(let code):
            "SQLite backup failed with code \(code)"
        case .queryFailed(let message):
            message
        }
    }
}

enum SWStoreCheckpoint {
    private static let sidecarSuffixes = ["-wal", "-shm"]

    /// Copies a live SwiftData store (including uncheckpointed WAL pages) into a standalone file.
    static func backupStore(from sourceURL: URL, to destinationURL: URL) throws {
        removeStoreFiles(at: destinationURL)

        var sourceDatabase: OpaquePointer?
        guard sqlite3_open_v2(sourceURL.path, &sourceDatabase, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let sourceDatabase
        else {
            throw SWStoreCheckpointError.openFailed(sourceURL.path)
        }
        defer { sqlite3_close(sourceDatabase) }

        var destinationDatabase: OpaquePointer?
        guard sqlite3_open_v2(
            destinationURL.path,
            &destinationDatabase,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
            nil
        ) == SQLITE_OK,
            let destinationDatabase
        else {
            throw SWStoreCheckpointError.openFailed(destinationURL.path)
        }
        defer { sqlite3_close(destinationDatabase) }

        sqlite3_busy_timeout(sourceDatabase, 60_000)
        sqlite3_busy_timeout(destinationDatabase, 60_000)

        guard let backup = sqlite3_backup_init(destinationDatabase, "main", sourceDatabase, "main") else {
            throw SWStoreCheckpointError.backupFailed(sqlite3_errcode(destinationDatabase))
        }
        defer { sqlite3_backup_finish(backup) }

        var result: Int32 = SQLITE_OK
        while result == SQLITE_OK {
            result = sqlite3_backup_step(backup, 128)
        }
        guard result == SQLITE_DONE else {
            throw SWStoreCheckpointError.backupFailed(result)
        }

        try truncateWAL(at: destinationURL)
    }

    /// Merges WAL pages into the main store file and removes `-wal`/`-shm` sidecars.
    static func truncateWAL(at storeURL: URL) throws {
        var database: OpaquePointer?
        guard sqlite3_open_v2(storeURL.path, &database, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK,
              let database
        else {
            throw SWStoreCheckpointError.openFailed(storeURL.path)
        }
        defer { sqlite3_close(database) }

        sqlite3_busy_timeout(database, 60_000)

        var logFrames: Int32 = 0
        var checkpointedFrames: Int32 = 0
        let result = sqlite3_wal_checkpoint_v2(
            database,
            nil,
            SQLITE_CHECKPOINT_TRUNCATE,
            &logFrames,
            &checkpointedFrames
        )
        guard result == SQLITE_OK else {
            throw SWStoreCheckpointError.checkpointFailed(result)
        }

        removeSidecars(for: storeURL)
    }

    static func entryCount(in storeURL: URL) throws -> Int {
        try queryInt(in: storeURL, sql: "SELECT COUNT(*) FROM ZENTRY;")
    }

    static func maxEntryID(in storeURL: URL) throws -> Int {
        try queryInt(in: storeURL, sql: "SELECT MAX(ZENTRYID) FROM ZENTRY;")
    }

    static func removeStoreFiles(at storeURL: URL) {
        let fileManager = FileManager.default
        let paths = [storeURL.path] + sidecarSuffixes.map { storeURL.path + $0 }
        for path in paths where fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
    }

    private static func removeSidecars(for storeURL: URL) {
        let fileManager = FileManager.default
        for suffix in sidecarSuffixes {
            let sidecar = URL(fileURLWithPath: storeURL.path + suffix)
            if fileManager.fileExists(atPath: sidecar.path) {
                try? fileManager.removeItem(at: sidecar)
            }
        }
    }

    private static func queryInt(in storeURL: URL, sql: String) throws -> Int {
        var database: OpaquePointer?
        guard sqlite3_open_v2(storeURL.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let database
        else {
            throw SWStoreCheckpointError.openFailed(storeURL.path)
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement
        else {
            throw SWStoreCheckpointError.queryFailed("Failed to prepare query: \(sql)")
        }
        defer { sqlite3_finalize(statement) }

        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw SWStoreCheckpointError.queryFailed("Failed to read query result: \(sql)")
        }

        return Int(sqlite3_column_int64(statement, 0))
    }
}
#endif
