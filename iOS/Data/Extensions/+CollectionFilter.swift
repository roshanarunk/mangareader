//
//  +CollectionFilter.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-01.
//

import Foundation
import RealmSwift

enum ContentSelectionType: Int, PersistableEnum, CaseIterable, Identifiable, Codable {
    case none, only, both

    var description: String {
        switch self {
        case .none:
            return "None"
        case .only:
            return "Only"
        case .both:
            return "Both"
        }
    }

    var id: Int {
        hashValue
    }
}

enum ExternalContentType: Int, PersistableEnum, CaseIterable, Identifiable, Codable {
    case manga, manhua, manhwa, comic, novel

    var id: Int {
        hashValue
    }

    var description: String {
        switch self {
        case .novel:
            return "Novel"
        case .manga:
            return "Manga"
        case .manhua:
            return "Manhua"
        case .manhwa:
            return "Manhwa"
        case .comic:
            return "Comic"
        }
    }
}
