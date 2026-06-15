//
//  BrowseTabView.swift
//  Shuowen
//

import SwiftData
import SwiftUI

struct BrowseTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Entry.entryID) private var allEntries: [Entry]

    @State private var searchText = ""
    @State private var searchResults: [Entry]?
    @State private var searchTask: Task<Void, Never>?

    private var isDatabaseReady: Bool {
        !allEntries.isEmpty
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isDatabaseReady {
                    browseContent
                } else {
                    DatabaseUnavailableView()
                }
            }
            .navigationTitle("Browse")
            .toolbarTitleDisplayMode(.inlineLarge)
            .shuowenSearchable(
                text: $searchText,
                prompt: "Headword / pinyin / radical / index"
            )
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    searchTask?.cancel()
                    searchResults = nil
                } else {
                    scheduleSearch(immediate: false)
                }
            }
        }
    }

    @ViewBuilder
    private var browseContent: some View {
        if isSearching {
            if let searchResults, searchResults.isEmpty {
                SWContentUnavailableView(
                    title: "No Results",
                    systemImage: "character.book.closed",
                    description: "No matches for \"\(searchText)\"."
                )
            } else {
                #if DEBUG
                EntryGridView(entries: searchResults ?? [], showsEntryID: true)
                #else
                EntryGridView(entries: searchResults ?? [])
                #endif
            }
        } else {
            #if DEBUG
            EntryGridView(entries: allEntries, showsEntryID: true)
            #else
            EntryGridView(entries: allEntries)
            #endif
        }
    }

    private func scheduleSearch(immediate: Bool) {
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            if !immediate {
                try? await Task.sleep(for: .milliseconds(250))
            }
            guard !Task.isCancelled else { return }
            performSearch()
        }
    }

    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            searchResults = nil
            return
        }

        let store = SWEntryStore(context: modelContext)
        do {
            let termResults = try store.search(term: query)
            if !termResults.isEmpty {
                searchResults = termResults
                return
            }
            searchResults = try store.searchExplanation(containing: query)
        } catch {
            searchResults = []
            #if DEBUG
            print("Search failed: \(error)")
            #endif
        }
    }
}
