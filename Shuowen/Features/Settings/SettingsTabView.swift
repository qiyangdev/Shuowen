//
//  SettingsTabView.swift
//  Shuowen
//

import SwiftData
import SwiftUI

struct SettingsTabView: View {
    @Query(sort: \Entry.entryID) private var allEntries: [Entry]
    @Query private var favorites: [FavoriteEntry]

    private var appVersion: String {
        let version =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? "—"
        let build =
            Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Data") {
                    LabeledContent("Entries", value: "\(allEntries.count)")
                    LabeledContent("Favorites", value: "\(favorites.count)")
                    LabeledContent(
                        "Database",
                        value: allEntries.isEmpty
                            ? String(localized: "Not installed")
                            : String(localized: "Ready")
                    )
                }

                Section("About") {
                    LabeledContent("App", value: "Shuowen")
                    LabeledContent("Version", value: appVersion)
                    Link(destination: ProjectInfo.repositoryURL) {
                        Text("GitHub")
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        OpenSourceLicensesView()
                    } label: {
                        Text("Acknowledgments")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}
