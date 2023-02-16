//
//  Migration+StrategySelectorView.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-27.
//

import SwiftUI

struct MigrationStrategySelectorView: View {
    @EnvironmentObject private var model: MigrationController

    var body: some View {
        Section {
            Picker("Migration Strategy", selection: $model.libraryStrat) {
                ForEach(LibraryMigrationStrategy.allCases, id: \.hashValue) {
                    Text($0.description)
                        .tag($0)
                }
            }

            Picker("On Replacement with Less Chapters", selection: $model.lessChapterSrat) {
                ForEach(LowerChapterMigrationStrategy.allCases, id: \.hashValue) {
                    Text($0.description)
                        .tag($0)
                }
            }
            Picker("On Replacement Not Found", selection: $model.notFoundStrat) {
                ForEach(NotFoundMigrationStrategy.allCases, id: \.hashValue) {
                    Text($0.description)
                        .tag($0)
                }
            }

        } header: {
            Text("Pre-Migration")
        }
        .buttonStyle(.plain)
        .disabled(model.contents.isEmpty)

        Section {
            Text("^[\(foundMatches) Match](inflect: true) of ^[\(titleCount) Title](inflect: true) (\(foundMatches)/\(titleCount))")
                .foregroundColor(.gray)

            Button { model.filterNonMatches() } label: {
                Label("Filter Out Non-Matches", systemImage: "line.3.horizontal.decrease.circle")
            }
        } header: {
            Text("Matches")
        }
        .buttonStyle(.plain)
        .disabled(model.contents.isEmpty)

        Section {
            Button { model.presentConfirmationAlert.toggle() } label: {
                Label("Start Migration", systemImage: "shippingbox")
            }
        } header: {
            Text("Start")
        }
        .buttonStyle(.plain)
        .disabled(model.contents.isEmpty)
    }

    private var foundMatches: Int {
        model
            .operations
            .filter(\.value.found)
            .count
    }

    private var titleCount: Int {
        model
            .contents
            .count
    }
}
