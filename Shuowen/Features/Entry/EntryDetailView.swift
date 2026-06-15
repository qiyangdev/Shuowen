//
//  EntryDetailView.swift
//  Shuowen
//
//  Created by wangqiyang on 2026/6/12.
//

import SwiftData
import SwiftUI

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let entry: Entry

    @State private var isFavorite = false

    var body: some View {
        List {
            Section {
                Text(entry.wordhead)
                    .font(SWFont.display)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)

            Section {
                LabeledContent("Pinyin") {
                    Text(entry.pinyinFull)

                }
                LabeledContent("Pronunciation") {
                    Text(entry.pronunciation)
                        .font(SWFont.body)
                }
            }

            Section {
                Text(entry.explanation)
                    .font(SWFont.body)
            } header: {
                Text("Gloss")
            }

            if !entry.variants.isEmpty {
                Section {
                    ForEach(entry.variants, id: \.persistentModelID) {
                        variant in
                        LabeledContent {
                            Text(variant.explanation)
                                .font(SWFont.body)
                        } label: {
                            Text(variant.wordhead)
                                .font(SWFont.title)
                            //                            if !variant.sealCharacter.isEmpty {
                            //                                Text(variant.sealCharacter)
                            //                                    .font(SWFont.body)
                            //                            }
                        }

                    }
                } header: {
                    Text("Variants")
                }
            }

            if !entry.duanNotes.isEmpty {
                Section {
                    ForEach(entry.duanNotes, id: \.persistentModelID) {
                        duanNote in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(duanNote.explanation)
                                .font(SWFont.body)
                            Text(duanNote.note)
                                .lineSpacing(4)
                                .font(SWFont.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    sectionHeader("Duan Notes")
                }
            }

            if !entry.xuanNote.isEmpty {
                Section {
                    Text(entry.xuanNote)
                        .font(SWFont.body)
                } header: {
                    sectionHeader("Xuan Note")
                }
            }

            if !entry.kaiNote.isEmpty {
                Section {
                    Text(entry.kaiNote)
                        .font(SWFont.body)
                } header: {
                    sectionHeader("Kai Note")
                }
            }

            Section {
                LabeledContent("Radical") {
                    Text(entry.radical)
                        .font(SWFont.subheadline)
                }
                LabeledContent("Volume") {
                    Text(entry.volume)
                        .font(SWFont.subheadline)
                }
                if !entry.sealCharacter.isEmpty {
                    LabeledContent("Seal Character") {
                        Text(entry.sealCharacter)
                            .font(SWFont.subheadline)
                    }
                }
            } header: {
                sectionHeader("Radical / Volume")
            }

            //            if !entry.indexes.isEmpty {
            //                Section {
            //                    ForEach(entry.indexes, id: \.self) { idx in
            //                        Text(idx)
            //                            .font(SWFont.body)
            //                    }
            //                } header: {
            //                    sectionHeader("Index Forms")
            //                }
            //            }
            //
            //            if !entry.components.isEmpty {
            //                Section {
            //                    ForEach(entry.components, id: \.self) { component in
            //                        Text(component)
            //                            .font(SWFont.body)
            //                    }
            //                } header: {
            //                    sectionHeader("Components")
            //                }
            //            }
        }
        .textSelection(.enabled)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                }
                .accessibilityLabel(
                    isFavorite
                        ? String(localized: "Remove from Favorites")
                        : String(localized: "Add to Favorites")
                )
            }
        }
        .task {
            refreshFavoriteState()
        }
    }

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
    }

    private func refreshFavoriteState() {
        let store = SWFavoriteStore(context: modelContext)
        isFavorite = (try? store.isFavorite(entryID: entry.entryID)) ?? false
    }

    private func toggleFavorite() {
        let store = SWFavoriteStore(context: modelContext)
        isFavorite = (try? store.toggle(entryID: entry.entryID)) ?? isFavorite
    }
}

private struct EntryDetailPreviewHost: View {
    private let container: ModelContainer
    private let entry: Entry

    init() {
        let container = try! ModelContainer(
            for: Entry.self,
            Variant.self,
            DuanNote.self,
            FavoriteEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let entry = try! EntryPreviewData.makeEntry()
        container.mainContext.insert(entry)
        self.container = container
        self.entry = entry
    }

    var body: some View {
        NavigationStack {
            EntryDetailView(entry: entry)
        }
        .modelContainer(container)
    }
}

#Preview("Entry Detail") {
    EntryDetailPreviewHost()
}
