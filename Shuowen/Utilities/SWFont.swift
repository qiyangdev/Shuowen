//
//  SWFont.swift
//  Shuowen
//
//  Jigmo → Jigmo2 → Jigmo3 cascade for entry card and detail text.

import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

enum SWFont {
    static let primaryPostScriptName = "Jigmo"
    static let fallbackPostScriptNames = ["Jigmo2", "Jigmo3"]

    static var caption: Font { appFont(size: 12) }
    static var subheadline: Font { appFont(size: 15) }
    static var body: Font { appFont(size: 17) }
    static var title: Font { appFont(size: 22) }
    static var cardHead: Font { appFont(size: 36) }
    static var display: Font { appFont(size: 256) }

    static func appFont(size: CGFloat) -> Font {
        #if canImport(UIKit)
            if let uiFont = uiFont(size: size) {
                return Font(uiFont)
            }
        #elseif canImport(AppKit)
            return Font(nsFont(size: size))
        #endif
        return .custom(primaryPostScriptName, size: size)
    }

    #if canImport(UIKit)
        static func uiFont(size: CGFloat) -> UIFont? {
            guard
                let primaryFont = UIFont(
                    name: primaryPostScriptName,
                    size: size
                )
            else {
                return nil
            }

            let cascadeDescriptors = fallbackPostScriptNames.compactMap {
                name -> UIFontDescriptor? in
                guard UIFont(name: name, size: size) != nil else { return nil }
                return UIFontDescriptor(fontAttributes: [
                    .name: name,
                    .size: 0,
                ])
            }

            guard !cascadeDescriptors.isEmpty else { return primaryFont }

            let descriptor = primaryFont.fontDescriptor.addingAttributes([
                .cascadeList: cascadeDescriptors
            ])
            return UIFont(descriptor: descriptor, size: size)
        }
    #endif

    #if canImport(AppKit)
        static func nsFont(size: CGFloat) -> NSFont {
            guard
                let primaryFont = NSFont(
                    name: primaryPostScriptName,
                    size: size
                )
            else {
                return NSFont(name: primaryPostScriptName, size: size)
                    ?? NSFont.systemFont(ofSize: size)
            }

            let cascadeDescriptors = fallbackPostScriptNames.compactMap {
                name -> NSFontDescriptor? in
                guard NSFont(name: name, size: size) != nil else { return nil }
                return NSFontDescriptor(fontAttributes: [
                    .name: name,
                    .size: 0,
                ])
            }

            guard !cascadeDescriptors.isEmpty else { return primaryFont }

            let descriptor = primaryFont.fontDescriptor.addingAttributes([
                .cascadeList: cascadeDescriptors
            ])
            return NSFont(descriptor: descriptor, size: size) ?? primaryFont
        }
    #endif
}

struct SWContentUnavailableView: View {
    let title: LocalizedStringKey
    let systemImage: String
    let description: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)

            Text(title)
                .font(.title2)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
