//
//  JSCC+Logging.swift
//  Mangareader (iOS)
//
//  Made on on 2023-03-18.
//

import Foundation
import JavaScriptCore

extension JSCHandler {
    @objc class LogHandler: JSObject, JSCHandlerProtocol {
        func _post(_ message: JSValue) -> JSValue {
            let output = JSValue(nullIn: message.context)!
            let message = message.toDictionary() as? [String: String]

            guard let message else {
                Logger.shared.error("Failed to Convert Handler Message")
                return output
            }
            log(message: message)
            return output
        }
    }
}

extension JSCHandler.LogHandler {
    func log(message: [String: String]) {
        guard let level = Logger.Level(rawValue: message["level"] ?? "LOG"), let msg = message["message"], let context = message["context"] else {
            Logger.shared.log("\(message)")
            return
        }
        Logger.shared.log(level: level, msg, context)
    }
}
