//
//  CustomThumbnail.swift
//  Mangareader (iOS)
//
//  Made on on 2023-05-30.
//

import Foundation
import IceCream
import RealmSwift

final class CustomThumbnail: Object, Identifiable, CKRecordConvertible, CKRecordRecoverable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var file: CreamAsset?
    @Persisted var isDeleted: Bool = false
    static let FILE_KEY = "custom_thumb"
}
