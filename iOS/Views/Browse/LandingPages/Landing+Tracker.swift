//
//  Landing+Tracker.swift
//  Mangareader (iOS)
//
//  Made on on 2023-07-13.
//

import SwiftUI

struct TrackerLandingPage: View {
    let trackerID: String
    @State var loadable = Loadable<AnyContentTracker>.idle

    var body: some View {
        LoadableView(trackerID, load, $loadable) {
            LoadedTrackerView(tracker: $0)
        }
    }

    func load() async throws -> AnyContentTracker {
        try await DSK.shared.getContentTracker(id: trackerID)
    }

    struct LoadedTrackerView: View {
        let tracker: AnyContentTracker
        var body: some View {
            ZStack {
                if tracker.intents.pageLinkResolver {
                    ContentTrackerPageView(tracker: tracker, link: .init(id: "home", context: nil))
                } else {
                    ContentTrackerDirectoryView(tracker: tracker, request: .init(page: 1))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
