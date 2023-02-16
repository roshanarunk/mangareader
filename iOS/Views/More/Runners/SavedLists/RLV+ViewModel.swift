//
//  RLV+ViewModel.swift
//  Mangareader
//
//  Made on on 2023-08-15.
//

import RealmSwift
import SwiftUI

extension RunnerListsView {
    final class ViewModel: ObservableObject {
        @Published var savedRunners: [String: StoredRunnerObject] = [:]
        @Published var savedLists: [StoredRunnerList] = []

        private var runnersToken: NotificationToken?
        private var listToken: NotificationToken?

        func observe() async {
            let actor = await RealmActor.shared()

            // Runners
            runnersToken = await actor
                .observeInstalledRunners(onlyEnabled: false) { value in
                    let kv = value.map { ($0.id, $0) }
                    let prepped = Dictionary(uniqueKeysWithValues: kv)
                    Task { @MainActor [weak self] in
                        self?.savedRunners = prepped
                    }
                }

            // Lists
            listToken = await actor
                .observeSavedRunnerLists { value in
                    Task { @MainActor [weak self] in
                        self?.savedLists = value
                    }
                }
        }

        func stopObserving() {
            runnersToken?.invalidate()
            listToken?.invalidate()

            runnersToken = nil
            listToken = nil
        }
    }
}
