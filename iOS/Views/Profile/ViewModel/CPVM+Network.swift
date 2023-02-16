//
//  CPVM+Network.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-23.
//

import Foundation

private typealias ViewModel = ProfileView.ViewModel

extension ViewModel {
    func getContentFromSource() async throws -> DSKCommon.Content {
        try await source
            .getContent(id: entry.id)
    }

    func getChaptersFromSource() async throws -> [DSKCommon.Chapter] {
        try await source
            .getContentChapters(contentId: entry.id)
    }
}

extension ViewModel {}
