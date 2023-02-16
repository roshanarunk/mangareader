//
//  IV+ChapterList.swift
//  Mangareader
//
//  Made on on 2023-08-14.
//

import SwiftUI

struct IVChapterListView: View {
    @State private var showLangFlag = false
    @State private var showDate = false
    @State private var chapters: [ThreadSafeChapter] = []
    @EnvironmentObject private var model: IVViewModel

    private var activeChapter: ThreadSafeChapter {
        model.viewerState.chapter
    }

    var body: some View {
        SmartNavigationView {
            ScrollViewReader { proxy in
                List {
                    Section {
                        ChapterListTile(chapter: activeChapter,
                                        isCompleted: false,
                                        isNewChapter: false,
                                        progress: nil,
                                        download: nil,
                                        isLinked: false,
                                        showLanguageFlag: showLangFlag,
                                        showDate: showDate,
                                        isBookmarked: false)
                    } header: {
                        Text("Currently Reading")
                    }

                    Section {
                        ForEach(chapters, id: \.id) { chapter in
                            Button { didSelect(chapter) } label: {
                                ChapterListTile(chapter: chapter,
                                                isCompleted: false,
                                                isNewChapter: false,
                                                progress: nil,
                                                download: nil,
                                                isLinked: false,
                                                showLanguageFlag: showLangFlag,
                                                showDate: showDate,
                                                isBookmarked: false)
                            }
                            .listRowBackground(activeChapter.id == chapter.id ? Color.accentColor.opacity(0.05) : nil)
                        }
                    } header: {
                        Text("Chapter List")
                    }
                }
                .headerProminence(.increased)
                .task {
                    await loadSource()
                    await loadChapters()
                    proxy.scrollTo(activeChapter.id, anchor: .center)
                }
            }
            .closeButton()
            .navigationTitle("Chapters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension IVChapterListView {
    func didSelect(_ chapter: ThreadSafeChapter) {
        let id = activeChapter.id

        guard id != chapter.id else {
            return
        }

        model.pendingState = .init(chapter: chapter)
        withAnimation {
            model.toggleChapterList()
        }
    }

    func loadSource() async {
        let sourceId = activeChapter.sourceId
        if STTHelpers.isInternalSource(sourceId) { return }
        guard let source = await DSK.shared.getSource(id: sourceId) else { return }
        showLangFlag = source.ablityNotDisabled(\.disableLanguageFlags)
        showDate = source.ablityNotDisabled(\.disableChapterDates)
    }

    func loadChapters() async {
        let cache = model.dataCache
        chapters = Array(await cache.chapters)
    }
}
