//
//  CompactLibraryView.swift
//  Mangareader (iOS)
//
//  Made on on 2023-12-15.
//

import SwiftUI

struct CompactLibraryView: View {
    var body: some View {
        ZStack {
            LibraryView.LibraryGrid(collection: nil, readingFlag: nil, useLibrary: true)
        }
        .navigationTitle("Library")
    }
}
