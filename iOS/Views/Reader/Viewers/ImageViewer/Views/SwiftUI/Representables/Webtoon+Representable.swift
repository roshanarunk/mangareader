//
//  Webtoon+Representable.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-18.
//

import SwiftUI
import UIKit

struct WebtoonViewer: UIViewControllerRepresentable {
    @EnvironmentObject private var model: IVViewModel
    typealias UIViewControllerType = UINavigationController

    func makeUIViewController(context _: Context) -> UINavigationController {
        UINavigationController(rootViewController: WebtoonController(model: model))
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}
