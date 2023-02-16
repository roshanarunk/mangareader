//
//  Migration+Models.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-27.
//

import SwiftUI

enum MigrationOperationState {
    case idle, searching, searchComplete, migrationComplete

    var description: String {
        switch self {
        case .idle: return "Idle"
        case .searching: return "Searching"
        case .searchComplete: return "Pre-Migration"
        case .migrationComplete: return "Done!"
        }
    }
}

enum MigrationItemState: Equatable {
    case idle, searching, found(_ entry: TaggedHighlight), noMatches
    case lowerFind(_ entry: TaggedHighlight, _ initial: Double, _ next: Double)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.found, .found), (.noMatches, .noMatches), (.lowerFind, .lowerFind): return true
        default: return false
        }
    }

    func value() -> TaggedHighlight? {
        switch self {
        case .searching, .idle, .noMatches: return nil
        case let .found(entry), let .lowerFind(entry, _, _):
            return entry
        }
    }

    var color: Color {
        switch self {
        case .idle: return .gray
        case .searching: return .blue
        case .lowerFind: return .yellow
        case .noMatches: return .red
        case .found: return .green
        }
    }

    var found: Bool {
        switch self {
        case .idle, .searching, .noMatches: return false
        default: return true
        }
    }
}

enum LibraryMigrationStrategy: CaseIterable {
    case link, replace

    var description: String {
        switch self {
        case .link: return "Link"
        case .replace: return "Replace"
        }
    }
}

enum NotFoundMigrationStrategy: CaseIterable {
    case remove, skip
    var description: String {
        switch self {
        case .remove: return "Remove"
        case .skip: return "Skip"
        }
    }
}

enum LowerChapterMigrationStrategy: CaseIterable {
    case skip, migrate

    var description: String {
        switch self {
        case .migrate: return "Migrate Anyway"
        case .skip: return "Skip"
        }
    }
}
