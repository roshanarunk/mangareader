//
//  ReadingStatistics.swift
//  Mangareader (iOS)
//
//  Made on on 2023-09-13.
//

import IceCream
import RealmSwift

final class UserReadingStatistic: Object, Identifiable, CKRecordConvertible, CKRecordRecoverable {
    @Persisted(primaryKey: true) var id = "default"
    @Persisted var isDeleted: Bool

    @Persisted var pagesRead: Int
    @Persisted var pixelsScrolled: Double
}
