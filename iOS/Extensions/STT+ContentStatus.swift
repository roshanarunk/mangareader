//
//  STT+ContentStatus.swift
//  Mangareader
//
//  Made on on 2022-03-07.
//

import SwiftUI

extension ContentStatus {
    var description: String {
        switch self {
        case .UNKNOWN:
            return "Unknown Status"
        case .ONGOING:
            return "Ongoing"
        case .COMPLETED:
            return "Completed"
        case .CANCELLED:
            return "Cancelled"
        case .HIATUS:
            return "On Hiatus"
        }
    }

    var color: Color {
        switch self {
        case .UNKNOWN, .CANCELLED:
            return .red
        case .ONGOING:
            return .blue
        case .COMPLETED:
            return .green
        case .HIATUS:
            return .yellow
        }
    }
}
