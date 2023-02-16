//
//  +Chapter.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-01.
//

import Foundation

extension StoredChapter {
    func toThreadSafe() -> ThreadSafeChapter {
        return .init(id: id,
                     sourceId: sourceId,
                     chapterId: chapterId,
                     contentId: contentId,
                     index: index,
                     number: number,
                     volume: volume,
                     title: title,
                     language: language ?? "unknown",
                     date: date,
                     webUrl: webUrl,
                     thumbnail: thumbnail, providers: providers.map { .init(id: $0.id, name: $0.name) })
    }
}

extension StoredChapter {
    func generateReference() -> ChapterReference {
        let object = ChapterReference()
        object.id = id
        object.chapterId = chapterId
        object.number = number
        object.volume = volume
        return object
    }
}

extension DaisukeEngine.Structs.Chapter {
    func toStoredChapter(sourceID: String, contentID: String) -> StoredChapter {
        let chapter = StoredChapter()

        chapter.id = "\(sourceID)||\(contentID)||\(chapterId)"

        chapter.sourceId = sourceID
        chapter.contentId = contentID
        chapter.chapterId = chapterId

        chapter.number = number
        chapter.volume = (volume == nil || volume == 0.0) ? nil : volume
        chapter.title = title
        chapter.language = language

        chapter.date = date
        chapter.index = index
        chapter.webUrl = webUrl
        chapter.thumbnail = thumbnail

        let providers = providers?.map { provider -> ChapterProvider in
            let p = ChapterProvider()
            p.name = provider.name
            p.id = provider.id
            return p
        } ?? []
        chapter.providers.append(objectsIn: providers)
        return chapter
    }
}

extension StoredChapter {
    static func == (lhs: StoredChapter, rhs: StoredChapter) -> Bool {
        lhs.id == rhs.id
    }
}

enum ChapterType {
    case EXTERNAL, LOCAL, OPDS
}
