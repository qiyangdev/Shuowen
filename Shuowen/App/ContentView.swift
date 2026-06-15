//
//  ContentView.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import SwiftData
import SwiftUI

private enum AppTab: Hashable {
    case roam
    case browse
    case favorites
    case settings
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .roam

    var body: some View {
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            modernTabView
        } else {
            legacyTabView
        }
    }

    @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
    private var modernTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Roam", systemImage: "shuffle", value: AppTab.roam) {
                RoamTabView()
            }

            Tab(
                "Browse",
                systemImage: "square.grid.2x2",
                value: AppTab.browse
            ) {
                BrowseTabView()
            }

            Tab("Favorites", systemImage: "star", value: AppTab.favorites) {
                FavoritesTabView()
            }

            Tab("Settings", systemImage: "gearshape", value: AppTab.settings) {
                SettingsTabView()
            }
        }
    }

    private var legacyTabView: some View {
        TabView(selection: $selectedTab) {
            RoamTabView()
                .tabItem {
                    Label("Roam", systemImage: "shuffle")
                }
                .tag(AppTab.roam)

            BrowseTabView()
                .tabItem {
                    Label("Browse", systemImage: "square.grid.2x2")
                }
                .tag(AppTab.browse)

            FavoritesTabView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(AppTab.favorites)

            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(AppTab.settings)
        }
    }
}

#Preview("Content") {
    ContentView()
        .modelContainer(
            for: [Entry.self, Variant.self, DuanNote.self, FavoriteEntry.self],
            inMemory: true
        )
}
