//
//  DSK+Form.swift
//  Mangareader (iOS)
//
//  Made on on 2023-08-31.
//

import AnyCodable
import Foundation

extension DSKCommon {
    enum UIComponentType: Int, Codable {
        case picker,
             multipicker,
             stepper,
             toggle,
             textfield,
             button,
             datepicker
    }

    struct UISection<T: Parsable>: Parsable, Hashable where T: Hashable {
        let header: String?
        let footer: String?
        let children: [T]
    }

    struct Form: Parsable, Hashable {
        let sections: [UISection<FormComponent>]
    }
}

extension DSKCommon {
    enum FormKeyboardType: String, Codable {
        case alphanumberic, numberic, email
    }

    struct FormComponent: Parsable, Hashable {
        let id: String
        let title: String
        let type: UIComponentType
        let options: [Option]?

        let value: AnyCodable?
        private let optional: AnyCodable?

        // Pickers
        let minSelectionCount: Int?
        let maxSelectionCount: Int?

        // Textfield
        let placeholder: String?
        let secure: Bool?
        let keyboard: FormKeyboardType?
        let multiline: Bool?

        // Stepper
        let upperBound: Double?
        let lowerBound: Double?
        let allowDecimal: AnyCodable?
        let step: Double?

        // Button
        let isDestructive: Bool?
        let systemImage: String?

        var isOptional: Bool {
            !(optional == nil || optional?.value == nil)
        }

        var allowsDecimal: Bool {
            !(allowDecimal == nil || allowDecimal?.value == nil)
        }
    }
}
