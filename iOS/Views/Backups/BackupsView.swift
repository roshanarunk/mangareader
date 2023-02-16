//
//  BackupsView.swift
//  Mangareader (iOS)
//
//  Made on on 2022-04-06.
//

import Combine
import SwiftUI

struct BackupsView: View {
    @StateObject var manager = BackupManager.shared
    @State var selection: URL? {
        didSet {
            presentAlert.toggle()
        }
    }

    @State var presentActions = false
    @State var presentAlert = false
    @State var presentImporter = false
    @State var restoreTask: Task<Void, Never>? = nil
    private let downloader = CloudDownloader()
    var body: some View {
        List {
            ForEach(manager.urls, id: \.path) { url in
                let title = url.deletingPathExtension().lastPathComponent.trimmingCharacters(in: .punctuationCharacters)
                Button(title) {
                    selection = url
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button { handleShareURL(url: url) } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        manager.remove(url: url)
                    }
                }
            }
        }

        .alert("Restoring \(selection?.deletingPathExtension().lastPathComponent ?? "")\nThis action cannot be undone and all current data will be lost. If this is not a fresh install, please backup your data.", isPresented: $presentAlert) {
            Button("Cancel", role: .cancel) {}
            if let selection = selection {
                Button("Restore", role: .destructive) {
                    handleRestore(url: selection)
                }
            }
        }
        .navigationTitle("Backups")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        Task {
                            await saveNewBackup()
                        }
                    } label: {
                        Label("Create Backup", systemImage: "plus")
                    }

                    Button { presentImporter.toggle() } label: {
                        Label("Import Backup", systemImage: "tray.and.arrow.down.fill")
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .animation(.default, value: manager.urls)
        .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.json], onCompletion: { result in
            switch result {
            case let .success(url):
                if url.startAccessingSecurityScopedResource() {
                    // Copy To Local Document
                    do {
                        try BackupManager.shared.import(from: url)
                        ToastManager.shared.info("Imported Backup")
                    } catch {
                        ToastManager.shared.error(error)
                    }
                    url.stopAccessingSecurityScopedResource()
                }

            case let .failure(error):
                ToastManager.shared.error(error)
            }
        })
        .protectContent()
    }
}

extension BackupsView {
    func saveNewBackup() async {
        ToastManager.shared.block {
            try await BackupManager.shared.save()
        }
    }

    func handleShareURL(url: URL) {
        let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        let window = getKeyWindow()
        guard let controller = window?.rootViewController else { return }

        // Handle popover for iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityController.popoverPresentationController?.sourceView = controller.view
            // You might want to adjust this to be more specific, like the center of the screen, or near a specific button.
            activityController.popoverPresentationController?.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
        }

        controller.present(activityController, animated: true, completion: nil)
    }

    func handleRestore(url: URL) {
        ToastManager.shared.loading = true

        restoreTask = Task {
            do {
                try await manager.restore(from: url)
                await MainActor.run(body: {
                    ToastManager.shared.loading = false
                    ToastManager.shared.info("Restored Backup!")
                })
            } catch {
                Logger.shared.error("[BackUpView] [Restore] \(error)")
                await MainActor.run(body: {
                    ToastManager.shared.error(error)
                    ToastManager.shared.loading = false
                })
            }
        }
    }
}
