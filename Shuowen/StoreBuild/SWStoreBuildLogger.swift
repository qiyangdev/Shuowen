//
//  SWStoreBuildLogger.swift
//  Shuowen
//

#if DEBUG
import Foundation

enum SWStoreBuildLogger {
    private static let lock = NSLock()
    private static var logURL: URL?

    static func configure(logURL: URL?) {
        self.logURL = logURL
    }

    static func bootstrap() {
        guard SWDataStore.isStoreBuildLaunch else { return }
        log("Shuowen store builder started.")
        log("Arguments: \(ProcessInfo.processInfo.arguments.joined(separator: " "))")
    }

    static func log(_ message: String) {
        let line = message + "\n"
        print(message)
        fputs(line, stderr)
        fflush(stderr)

        lock.lock()
        defer { lock.unlock() }

        guard let logURL else { return }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: logURL.path) {
            fileManager.createFile(atPath: logURL.path, contents: nil)
        }
        if let handle = try? FileHandle(forWritingTo: logURL) {
            handle.seekToEndOfFile()
            if let data = line.data(using: .utf8) {
                handle.write(data)
            }
            try? handle.close()
        }
    }
}
#endif
