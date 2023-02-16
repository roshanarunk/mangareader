//
//  +ChapterData.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-01.
//

import Foundation

extension DaisukeEngine.Structs.ChapterData {
    func toStored(withStoredChapter chapter: StoredChapter) -> StoredChapterData {
        let object = StoredChapterData()
        object.chapter = chapter

        if let pages {
            for page in pages {
                let stored = StoredChapterPage()
                stored.url = page.url
                stored.raw = page.raw
                object.pages.append(stored)
            }
        }
        object.text = text
        return object
    }
}

extension StoredChapterData {
    func toReadableChapterData(with chapter: ThreadSafeChapter) -> ReaderChapterData {
        let chapterPages: [DSKCommon.ChapterPage] = pages.map { .init(url: $0.url, raw: $0.raw) }
        return .init(chapter: chapter,
                     pages: chapterPages,
                     text: text, urls: urls,
                     archivePaths: archivePaths,
                     archiveFile: archiveURL,
                     opdsInfo: opdsInfo)
    }
}
