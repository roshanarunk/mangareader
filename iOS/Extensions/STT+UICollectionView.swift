//
//  STT+UICollectionView.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-09.
//

import UIKit

extension UICollectionView {
    var currentPoint: CGPoint {
        .init(x: contentOffset.x + frame.midX, y: contentOffset.y + frame.midY)
    }

    var currentPath: IndexPath? {
        indexPathForItem(at: currentPoint)
    }

    var pathAtCenterOfScreen: IndexPath? {
        indexPathForItem(at: currentPoint)
    }
}
