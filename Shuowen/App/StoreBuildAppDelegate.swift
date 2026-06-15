//
//  StoreBuildAppDelegate.swift
//  Shuowen
//

#if DEBUG
import SwiftData

#if os(macOS)
import AppKit

final class StoreBuildAppDelegate: NSObject, NSApplicationDelegate {
    static var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        startStoreBuildIfNeeded()
    }

    private func startStoreBuildIfNeeded() {
        guard SWDataStore.isStoreBuildLaunch else { return }
        guard let container = Self.modelContainer else {
            SWStoreBuildLogger.log("Import failed: ModelContainer is nil.")
            StoreBuildRunner.quitIfNeeded()
            return
        }

        SWStoreBuildLogger.log("applicationDidFinishLaunching – starting import.")

        Task { @MainActor in
            defer { StoreBuildRunner.quitIfNeeded() }
            await StoreBuildRunner.run(container: container)
        }
    }
}

#else
import UIKit

final class StoreBuildAppDelegate: NSObject, UIApplicationDelegate {
    static var modelContainer: ModelContainer?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        startStoreBuildIfNeeded()
        return true
    }

    private func startStoreBuildIfNeeded() {
        guard SWDataStore.isStoreBuildLaunch else { return }
        guard let container = Self.modelContainer else {
            SWStoreBuildLogger.log("Import failed: ModelContainer is nil.")
            StoreBuildRunner.quitIfNeeded()
            return
        }

        SWStoreBuildLogger.log("application:didFinishLaunching – starting import.")

        Task { @MainActor in
            defer { StoreBuildRunner.quitIfNeeded() }
            await StoreBuildRunner.run(container: container)
        }
    }
}
#endif
#endif
