//
//  ShuowenSearchable.swift
//  Shuowen
//

import SwiftUI

extension View {
    @ViewBuilder
    func shuowenNavigationSubtitle(_ subtitle: String) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            self.navigationSubtitle(subtitle)
        } else {
            self
        }
    }

    /// Uses a plain TextField on macOS to avoid Spotlight donation errors from `.searchable`.
    @ViewBuilder
    func shuowenSearchable(text: Binding<String>, prompt: LocalizedStringKey)
        -> some View
    {
        #if os(macOS)
            searchable(
                text: text,
                placement: .automatic,
                prompt: prompt
            )
        #else
            searchable(
                text: text,
                placement: .navigationBarDrawer,
                prompt: prompt
            )
        #endif
    }
}
