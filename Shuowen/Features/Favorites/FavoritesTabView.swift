//
//  FavoritesTabView.swift
//  Shuowen
//

import SwiftData
import SwiftUI

struct FavoritesTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoriteEntry.createdAt, order: .reverse) private
        var favorites: [FavoriteEntry]

    @State private var favoriteEntries: [Entry] = []
    @State private var isDatabaseReady = false

    var body: some View {
        NavigationStack {
            Group {
                if !isDatabaseReady {
                    DatabaseUnavailableView()
                } else if favoriteEntries.isEmpty {
                    SWContentUnavailableView(
                        title: "No Favorites",
                        systemImage: "star",
                        description: "Tap the star on an entry to add it here."
                    )
                } else {
                    EntryGridView(entries: favoriteEntries)
                }
            }
            .navigationTitle("Favorites")
            .toolbarTitleDisplayMode(.inlineLarge)
            .task {
                await loadFavorites()
            }
            .onChange(of: favorites.map(\.entryID)) { _, _ in
                Task { await loadFavorites() }
            }
        }
    }

    @MainActor
    private func loadFavorites() async {
        let store = SWEntryStore(context: modelContext)
        isDatabaseReady = (try? store.entryCount()) ?? 0 > 0

        guard isDatabaseReady else {
            favoriteEntries = []
            return
        }

        let favoriteStore = SWFavoriteStore(context: modelContext)
        favoriteEntries = (try? favoriteStore.favoriteEntries()) ?? []
    }
}
