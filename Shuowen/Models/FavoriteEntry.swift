//
//  FavoriteEntry.swift
//  Shuowen
//

import Foundation
import SwiftData

@Model
final class FavoriteEntry {
    var entryID: Int = 0
    var createdAt: Date = Date()

    init(entryID: Int) {
        self.entryID = entryID
        self.createdAt = Date()
    }
}
