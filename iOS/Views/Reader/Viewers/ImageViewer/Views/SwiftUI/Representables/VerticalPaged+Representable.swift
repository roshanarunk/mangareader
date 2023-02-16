//
//  VerticalPaged+Representable.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-09.
//

import SwiftUI

struct VerticalPagedViewer: UIViewControllerRepresentable {
    @EnvironmentObject private var model: IVViewModel
    typealias UIViewControllerType = IVPagingController

    func makeUIViewController(context _: Context) -> IVPagingController {
        let controller = IVPagingController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.model = model
        controller.isVertical = true
        return controller
    }

    func updateUIViewController(_: IVPagingController, context _: Context) {}
}
