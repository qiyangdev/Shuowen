//
//  ThirdPartyNotices.swift
//  Shuowen
//

import Foundation

struct ThirdPartyNotice: Identifiable, Hashable {
    let id: String
    let title: String
    let licenseName: String
    let homepage: URL
    let licenseURL: URL
    let noticeText: String
}

enum ThirdPartyNotices {
    static let shuowenDataURL = URL(
        string: "https://github.com/shuowenjiezi/shuowen"
    )!
    static let shuowenLicenseURL = URL(
        string: "https://www.apache.org/licenses/LICENSE-2.0"
    )!
    static let jigmoURL = URL(
        string: "https://kamichikoichi.github.io/jigmo/"
    )!
    static let cc0URL = URL(
        string: "https://creativecommons.org/publicdomain/zero/1.0/"
    )!

    static let all: [ThirdPartyNotice] = [shuowen, jigmo]

    static let shuowen = ThirdPartyNotice(
        id: "shuowen",
        title: "shuowenjiezi/shuowen",
        licenseName: "Apache License 2.0",
        homepage: shuowenDataURL,
        licenseURL: shuowenLicenseURL,
        noticeText: """
        Shuowen Dictionary Data
        Copyright 2019 Shuowen.org

        This application includes dictionary data derived from the \
        shuowenjiezi/shuowen project (https://github.com/shuowenjiezi/shuowen), \
        compiled into a local database for offline use.

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this data except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
        """
    )

    static let jigmo = ThirdPartyNotice(
        id: "jigmo",
        title: "Jigmo",
        licenseName: "CC0 1.0 Universal",
        homepage: jigmoURL,
        licenseURL: cc0URL,
        noticeText: """
        Jigmo (字雲) Font
        Koichi Uechi (上地宏一)

        This application embeds the Jigmo, Jigmo2, and Jigmo3 font files \
        from https://kamichikoichi.github.io/jigmo/ to display CJK characters.

        The font author has dedicated the font to the public domain under \
        CC0 1.0 Universal (CC0 1.0). To the extent possible under law, the \
        author has waived all copyright and related rights.

        You can copy, modify, distribute and perform the font, even for \
        commercial purposes, all without asking permission.

        Full license text:
        https://creativecommons.org/publicdomain/zero/1.0/
        """
    )
}
