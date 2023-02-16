//
//  DSK+Tag.swift
//  Mangareader (iOS)
//
//  Made on on 2022-07-27.
//

import Foundation

extension DaisukeEngine {
    struct Structs {}
}

extension DaisukeEngine.Structs {
    struct Property: Parsable, Identifiable, Hashable {
        var id: String
        var title: String
        var tags: [Tag]
    }

    struct Tag: Parsable, Hashable, Identifiable {
        var id: String
        var title: String
        var nsfw: Bool?
        var image: String?
        var noninteractive: Bool?

        var isNonInteractive: Bool {
            noninteractive ?? false
        }
    }

    struct Option: Parsable, Hashable, Identifiable {
        let id: String
        let title: String
    }
}
