//
//  CloudManager.swift
//  Mangareader (iOS)
//
//  Made on on 2023-05-27.
//

import Foundation

// Reference: https://stackoverflow.com/a/42950366
class CloudDataManager {
    static let shared = CloudDataManager()

    enum DocumentsDirectory {
        static let localDocumentsURL = FileManager.default.documentDirectory
        static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }

    // Return the Document directory (Cloud OR Local)
    // To do in a background thread

    func getDocumentDiretoryURL() -> URL {
        if isCloudEnabled {
            return DocumentsDirectory.iCloudDocumentsURL!
        } else {
            return DocumentsDirectory.localDocumentsURL
        }
    }

    // Return true if iCloud is enabled
    var isCloudEnabled: Bool {
        return DocumentsDirectory.iCloudDocumentsURL != nil && Preferences.standard.useCloudForLocal
    }

    // Delete All files at URL
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
            } catch let error as NSError {
                Logger.shared.error(error)
            }
        }
    }

    // Copy local files to iCloud
    // iCloud will be cleared before any operation
    // No data merging
    func copyLocalFilesToCloud() {
        guard isCloudEnabled else {
            return
        }
        deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear all files in iCloud Doc Dir
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL.path)
        while let file = enumerator?.nextObject() as? String {
            do {
                try fileManager.copyItem(at: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file), to: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
            } catch let error as NSError {
                Logger.shared.error(error)
            }
        }
    }

    // Copy iCloud files to local directory
    // Local dir will be cleared
    // No data merging
    func copyFilesToDevice() {
        if isCloudEnabled {
            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL)
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                do {
                    try fileManager.copyItem(at: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file), to: DocumentsDirectory.localDocumentsURL.appendingPathComponent(file))

                } catch let error as NSError {
                    Logger.shared.error(error)
                }
            }
        }
    }
}
