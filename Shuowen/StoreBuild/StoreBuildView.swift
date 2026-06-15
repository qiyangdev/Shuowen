//
//  StoreBuildView.swift
//  Shuowen
//

#if DEBUG
import SwiftUI

struct StoreBuildView: View {
    @State private var state = StoreBuildState.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: state.isFinished ? "checkmark.circle.fill" : "arrow.down.doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(state.isFinished ? .green : .accentColor)

            Text(state.isFinished ? "Import Complete" : "Building shuowen.store")
                .font(.title2)

            if state.total > 0 {
                ProgressView(value: Double(state.processed), total: Double(state.total))
                    .frame(maxWidth: 320)
                Text("\(state.processed) / \(state.total)")
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }

            Text(state.message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.footnote)
                .padding(.horizontal)

            if let errorMessage = state.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(40)
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 280)
        #endif
    }
}
#endif
