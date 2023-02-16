//
//  CPVM+ChapterList.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-26.
//

import Foundation
import SwiftUI

private typealias ViewModel = ProfileView.ViewModel

extension ViewModel {
    func getPreviewChapters(for statement: ChapterStatement) -> [ThreadSafeChapter] {
        let chapters = statement.filtered
        let targets = chapters.count >= 5 ? Array(chapters[0 ... 4]) : Array(chapters[0...])
        return targets
    }
}

extension ViewModel {
    // O(n)
    func prepareChapterStatement(_ chapters: [ThreadSafeChapter], content: SimpleContentInfo, loadChapters: Bool, index: Int) -> ChapterStatement {
        var maxOrderKey: Double = 0
        var distinctKeys = Set<Double>()

        let filtered = !loadChapters ? [] : STTHelpers.filterChapters(chapters, with: .init(contentId: content.highlight.id, sourceId: content.runnerID)) { chapter in
            let orderKey = chapter.chapterOrderKey
            maxOrderKey = max(orderKey, maxOrderKey)
            distinctKeys.insert(orderKey)
        }
        .sorted(by: \.index, descending: false)

        let distinctCount = distinctKeys.count
        return .init(content: content, filtered: filtered, originalList: chapters, distinctCount: distinctCount, maxOrderKey: maxOrderKey, index: index)
    }

    func getSortedChapters(_ chapters: [ThreadSafeChapter], onlyDownloaded: Bool, method: ChapterSortOption, descending: Bool) async -> [ThreadSafeChapter] {
        return await BGActor.run {
            func sort(_ chapters: [ThreadSafeChapter]) -> [ThreadSafeChapter] {
                switch method {
                case .date:
                    return chapters
                        .sorted(by: \.date, descending: descending)
                case .source:
                    return chapters
                        .sorted(by: \.index, descending: !descending) // Reverese Source Index
                case .number:
                    return chapters
                        .sorted(by: \.chapterOrderKey, descending: descending) // Reverese Source Index
                }
            }

            if onlyDownloaded {
                let filtered = sort(chapters
                    .filter { downloads[$0.id] == .completed })

                return filtered
            }

            let data = sort(chapters)

            return data
        }
    }

    func getCurrentStatement() -> ChapterStatement {
        chapterMap[currentChapterSection] ?? .init(content: contentInfo, filtered: [], originalList: [], distinctCount: 0, maxOrderKey: 0, index: 0)
    }

    func updateCurrentStatement() {
        let current = getCurrentStatement()
        let statement = prepareChapterStatement(current.originalList, content: current.content, loadChapters: true, index: current.index)
        withAnimation {
            chapterMap[current.content.contentIdentifier.id] = statement
        }
        Task {
            await setActionState()
        }
    }
}
