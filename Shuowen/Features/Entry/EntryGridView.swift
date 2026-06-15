//
//  EntryGridView.swift
//  Shuowen
//

import SwiftData
import SwiftUI

struct EntryGridView: View {
    let entries: [Entry]
    var showsEntryID: Bool = false

    private let gridColumns = [
        GridItem(.adaptive(minimum: 56, maximum: 112), spacing: 4)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 4) {
                ForEach(entries, id: \.persistentModelID) { entry in
                    NavigationLink {
                        EntryDetailView(entry: entry)
                    } label: {
                        EntryCardView(entry: entry, showsEntryID: showsEntryID)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DatabaseUnavailableView: View {
    var body: some View {
        SWContentUnavailableView(
            title: "Database Not Installed",
            systemImage: "externaldrive.badge.xmark",
            description:
                "Add the prebuilt shuowen.store file to the app bundle Resources folder."
        )
    }
}
