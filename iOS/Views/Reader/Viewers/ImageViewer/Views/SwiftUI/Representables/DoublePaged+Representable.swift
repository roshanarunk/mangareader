//
//  DoublePaged+Representable.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-08.
//

import SwiftUI
import UIKit

struct DoublePagedImageViewer: UIViewControllerRepresentable {
    @EnvironmentObject private var model: IVViewModel
    typealias UIViewControllerType = IVPagingController

    func makeUIViewController(context _: Context) -> IVPagingController {
        let controller = IVPagingController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.model = model
        controller.isDoublePager = true
        return controller
    }

    func updateUIViewController(_ controller: IVPagingController, context _: Context) {
        guard model.pendingState != nil && controller.isLoaded, controller.loadingTask == nil else { return }
        controller.hardReset()
        controller.startup()
    }
}

protocol DoublePageResolverDelegate: NSObject, UIContextMenuInteractionDelegate {
    func primaryIsWide(for page: PanelPage)
    func secondaryIsWide(for page: PanelPage)
}
