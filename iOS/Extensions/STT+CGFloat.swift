//
//  STT+CGFloat.swift
//  Mangareader (iOS)
//
//  Made on on 2022-03-30.
//

import SwiftUI

extension Double {
    func map(from: ClosedRange<Double>, to: ClosedRange<Double>) -> Double {
        let value = clamped(to: from)

        let fromRange = from.upperBound - from.lowerBound
        let toRange = to.upperBound - to.lowerBound
        let result = (((value - from.lowerBound) / fromRange) * toRange) + to.lowerBound
        return result
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
