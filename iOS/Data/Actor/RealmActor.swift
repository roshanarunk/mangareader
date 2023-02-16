//
//  RealmActor.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-01.
//

import Foundation
import RealmSwift

// Reference: https://www.mongodb.com/docs/realm/sdk/swift/actor-isolated-realm/#define-a-custom-realm-actor
actor RealmActor {
    // An implicitly-unwrapped optional is used here to let us pass `self` to
    // `Realm(actor:)` within `init`
    var realm: Realm!
    private init() async {
        realm = try! await Realm(actor: self)
    }

    private static var sharedTask: Task<RealmActor, Never>?

    static func shared() async -> RealmActor {
        if let sharedTask {
            return await sharedTask.value
        }
        let task = Task { await RealmActor() }
        sharedTask = task
        return await task.value
    }

    func close() {
        realm = nil
    }

    func operation(_ task: () -> Void) async {
        do {
            try await realm.asyncWrite {
                task()
            }
        } catch {
            if error is CancellationError {
                Logger.shared.warn("Write Operation Cancelled")
            } else {
                Logger.shared.error(error, "RealmActor")
            }
        }
    }
}
