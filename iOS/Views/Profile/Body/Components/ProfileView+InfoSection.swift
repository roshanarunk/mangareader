//
//  ProfileView+InfoSection.swift
//  Mangareader
//
//  Made on on 2022-03-07.
//

import Foundation
import SwiftUI

extension ProfileView.Skeleton {
    struct Summary: View {
        @State var expand = false
        @EnvironmentObject var model: ProfileView.ViewModel

        var entry: DSKCommon.Content {
            model.content
        }

        var summary: String? {
            entry.summary
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(entry.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textSelection(.enabled)

                    Spacer()
                }
                if let summary, summary.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
                    MarkDownView(text: summary)
                        .lineLimit(expand ? nil : 3)
                        .padding(.top, 5.0)
                        .onTapGesture {
                            withAnimation { expand.toggle() }
                        }
                } else { EmptyView() }
            }
            .frame(maxHeight: .infinity)
        }
    }

    struct CorePropertiesView: View {
        @EnvironmentObject var model: ProfileView.ViewModel
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if let properties = model.content.properties, !properties.isEmpty, let core = properties.get(index: 0) {
                    PropertyTagsView(property: core, source: model.source)
                }
            }
        }
    }

    struct PropertyTagsView: View {
        var property: DSKCommon.Property
        var source: AnyContentSource
        var body: some View {
            InteractiveTagView(property.tags) { tag in
                if source.ablityNotDisabled(\.disableTagNavigation) && !tag.isNonInteractive {
                    NavigationLink {
                        ContentSourceDirectoryView(source: source, request: generateSearchRequest(tagId: tag.id, propertyId: property.id))
                            .navigationBarTitle(tag.title)
                    } label: {
                        Text(tag.title)
                            .modifier(ProfileTagStyle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(tag.title)
                        .modifier(ProfileTagStyle())
                }
            }
        }

        fileprivate func generateSearchRequest(tagId: String, propertyId: String) -> DSKCommon.DirectoryRequest {
            .init(page: 1, tag: .init(tagId: tagId, propertyId: propertyId))
        }
    }
}

struct ProfileTagStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.callout.weight(.light))
            .padding(.vertical, 5)
            .padding(.horizontal, 8)
            .background(Color.primary.opacity(0.1))
            .foregroundColor(Color.primary)
            .cornerRadius(5)
    }
}
