//
//  DSK+Sync.swift
//  Mangareader (iOS)
//
//  Made on on 2022-09-27.
//

import Foundation

extension DSKCommon {
    struct UpSyncedContent: JSCObject {
        var id: String
        var flag: LibraryFlag
    }

    struct DownSyncedContent: JSCObject {
        var id: String
        var title: String
        var cover: String
        var readingFlag: LibraryFlag?
    }
}
