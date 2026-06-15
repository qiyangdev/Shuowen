//
//  OpenSourceLicensesView.swift
//  Shuowen
//

import SwiftUI

struct OpenSourceLicensesView: View {
    var body: some View {
        List(ThirdPartyNotices.all) { notice in
            NavigationLink {
                ThirdPartyLicenseDetailView(notice: notice)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(notice.title)
                        .font(.body)
                    Text(notice.licenseName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Open Source Licenses")
        .toolbarTitleDisplayMode(.inline)
    }
}

private struct ThirdPartyLicenseDetailView: View {
    let notice: ThirdPartyNotice

    var body: some View {
        List {
            Section {
                LabeledContent("License", value: notice.licenseName)
                Link(destination: notice.homepage) {
                    LabeledContent("Homepage") {
                        Text(notice.title)
                            .foregroundStyle(.tint)
                    }
                }
                Link("Full License Text", destination: notice.licenseURL)
            }

            Section("Notice") {
                Text(notice.noticeText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .navigationTitle(notice.title)
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OpenSourceLicensesView()
    }
}
