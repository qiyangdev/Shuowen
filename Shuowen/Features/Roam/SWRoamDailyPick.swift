//
//  SWRoamDailyPick.swift
//  Shuowen
//

import Foundation

enum SWRoamDailyPick {
    static let dateKey = "roamDailyDate"
    static let entryIDKey = "roamDailyEntryID"

    static func loadEntry(
        using store: SWEntryStore,
        calendar: Calendar = .current,
        now: Date = .now
    ) throws -> Entry? {
        let today = dayString(for: now, calendar: calendar)
        let defaults = UserDefaults.standard
        let storedDate = defaults.string(forKey: dateKey)
        let storedEntryID = defaults.integer(forKey: entryIDKey)

        if storedDate == today,
           storedEntryID > 0,
           let entry = try store.entry(id: storedEntryID) {
            return entry
        }

        return try refreshEntry(using: store, excludingEntryID: nil, calendar: calendar, now: now)
    }

    static func refreshEntry(
        using store: SWEntryStore,
        excludingEntryID: Int?,
        calendar: Calendar = .current,
        now: Date = .now
    ) throws -> Entry? {
        let entry = try store.randomEntry(excludingEntryID: excludingEntryID)
        if let entry {
            save(entryID: entry.entryID, calendar: calendar, now: now)
        }
        return entry
    }

    static func dayString(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day
        else {
            return ISO8601DateFormatter().string(from: date)
        }
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    private static func save(entryID: Int, calendar: Calendar, now: Date) {
        let defaults = UserDefaults.standard
        defaults.set(dayString(for: now, calendar: calendar), forKey: dateKey)
        defaults.set(entryID, forKey: entryIDKey)
    }
}
