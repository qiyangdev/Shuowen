//
//  RoamTabView.swift
//  Shuowen
//

import SwiftData
import SwiftUI

struct RoamTabView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var currentEntry: Entry?
    @State private var isDatabaseReady = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Group {
                if !isDatabaseReady {
                    DatabaseUnavailableView()
                } else if isLoading, currentEntry == nil {
                    ProgressView()
                } else if let currentEntry {
                    roamContent(for: currentEntry)
                } else {
                    SWContentUnavailableView(
                        title: "No Entries",
                        systemImage: "character.book.closed",
                        description: "No entries available."
                    )
                }
            }
            .navigationTitle("Roam")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Another", systemImage: "shuffle") {
                        Task { await refreshEntry() }
                    }
                    .disabled(!isDatabaseReady || isLoading)
                }
            }
            .task {
                await refreshDatabaseState()
                await loadDailyEntry()
            }
        }
    }

    @ViewBuilder
    private func roamContent(for entry: Entry) -> some View {
        VStack(spacing: 16) {
            NavigationLink {
                EntryDetailView(entry: entry)
            } label: {
                EntryCardView(entry: entry, style: .expanded)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
            .contentTransition(.identity)
            .id(entry.persistentModelID)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @MainActor
    private func refreshDatabaseState() async {
        let store = SWEntryStore(context: modelContext)
        isDatabaseReady = (try? store.entryCount()) ?? 0 > 0
    }

    @MainActor
    private func loadDailyEntry() async {
        guard isDatabaseReady else { return }

        isLoading = true
        defer { isLoading = false }

        let store = SWEntryStore(context: modelContext)
        let entry = try? SWRoamDailyPick.loadEntry(using: store)

        withAnimation(.easeInOut(duration: 0.2)) {
            currentEntry = entry
        }
    }

    @MainActor
    private func refreshEntry() async {
        guard isDatabaseReady else { return }

        isLoading = true
        defer { isLoading = false }

        let store = SWEntryStore(context: modelContext)
        let entry = try? SWRoamDailyPick.refreshEntry(
            using: store,
            excludingEntryID: currentEntry?.entryID
        )

        withAnimation(.easeInOut(duration: 0.2)) {
            currentEntry = entry
        }
    }
}
