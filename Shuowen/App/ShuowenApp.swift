//
//  ShuowenApp.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import SwiftData
import SwiftUI

@main
struct ShuowenApp: App {
    #if DEBUG
    #if os(macOS)
    @NSApplicationDelegateAdaptor(StoreBuildAppDelegate.self) private var storeBuildDelegate
    #else
    @UIApplicationDelegateAdaptor(StoreBuildAppDelegate.self) private var storeBuildDelegate
    #endif
    #endif

    private let modelContainer: ModelContainer

    #if DEBUG
    private let isStoreBuildLaunch = SWDataStore.isStoreBuildLaunch
    #endif

    init() {
        do {
            #if DEBUG
            if SWDataStore.isStoreBuildLaunch {
                SWStoreBuildLogger.configure(logURL: SWDataStore.launchLogURL)
                SWStoreBuildLogger.bootstrap()
                SWStoreBuildLogger.log("Resetting local store…")
                try SWDataStore.resetStoreForImport()
                SWStoreBuildLogger.log("Creating ModelContainer…")
            }
            #endif

            modelContainer = try SWDataStore.makeContainer()

            #if DEBUG
            if SWDataStore.isStoreBuildLaunch {
                SWStoreBuildLogger.log("ModelContainer ready.")
            }
            StoreBuildAppDelegate.modelContainer = modelContainer
            #endif
        } catch {
            #if DEBUG
            SWStoreBuildLogger.log("Failed to create ModelContainer: \(error)")
            #endif
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            if isStoreBuildLaunch {
                StoreBuildView()
            } else {
                ContentView()
            }
            #else
            ContentView()
            #endif
        }
        .modelContainer(modelContainer)
    }
}
