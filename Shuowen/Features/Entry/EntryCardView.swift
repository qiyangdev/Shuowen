//
//  EntryCardView.swift
//  Shuowen
//

import SwiftData
import SwiftUI

struct EntryCardView: View {
    enum Style {
        case compact
        case expanded
    }

    let entry: Entry
    var showsEntryID: Bool = false
    var style: Style = .compact

    var body: some View {
        VStack(spacing: 8) {
            Text(entry.wordhead)
                .font(style == .expanded ? SWFont.display : SWFont.cardHead)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: style == .expanded ? nil : 110,
            maxHeight: style == .expanded ? .infinity : nil
        )
    }
}

private struct EntryCardPreviewHost: View {
    let showsEntryID: Bool
    let style: EntryCardView.Style

    private let entry: Entry

    init(showsEntryID: Bool = false, style: EntryCardView.Style = .compact) {
        self.showsEntryID = showsEntryID
        self.style = style
        entry = try! EntryPreviewData.makeEntry()
    }

    var body: some View {
        EntryCardView(entry: entry, showsEntryID: showsEntryID, style: style)
    }
}

#Preview("Compact") {
    EntryCardPreviewHost()
}

#Preview("Expanded") {
    EntryCardPreviewHost(showsEntryID: true, style: .expanded)
        .padding()
}
