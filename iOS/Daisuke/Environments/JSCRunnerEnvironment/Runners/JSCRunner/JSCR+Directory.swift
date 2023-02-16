//
//  JSCR+Directory.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-03.
//

import Foundation

// MARK: - Directory Handler

extension JSCRunner: DSKDirectoryDelegate {
    func getDirectory(request: DSKCommon.DirectoryRequest) async throws -> DSKCommon.PagedResult {
        let object = try request.asDictionary()
        return try await callMethodReturningDecodable(method: "getDirectory", arguments: [object], resolvesTo: DSKCommon.PagedResult.self)
    }

    func getDirectoryConfig(key: String?) async throws -> DSKCommon.DirectoryConfig {
        if let config = configCache[key ?? "default"] {
            return config
        }
        let data: DSKCommon.DirectoryConfig = try await callMethodReturningDecodable(method: "getDirectoryConfig", arguments: [key as Any], resolvesTo: DSKCommon.DirectoryConfig.self)
        configCache[key ?? "default"] = data
        return data
    }
}
