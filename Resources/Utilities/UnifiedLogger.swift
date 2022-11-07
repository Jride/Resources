//
//  UnifiedLogger.swift
//  Resources
//
//  Created by Josh Rideout on 09/06/2020.
//

import Foundation
import os

public final class UnifiedLogger {
    
    public var enabled: Bool
    
    private var log: OSLog!
    private let category: String
    
    public init(category: String, enabled: Bool = true) {
        
        self.category = category
        self.enabled = enabled
        
        let subsystem = "com.itv.itvplayer"
        
        log = OSLog(subsystem: subsystem, category: category)
    }
    
    public func log(dynamic text: String) {
        self.log("%{public}@", text)
    }
    
    public func log(_ message: StaticString) {
        guard enabled else { return }
        os_log(message, log: log, type: .info)
    }
    
    public func log(_ message: StaticString, _ arg: String) {
        guard enabled else { return }
        os_log(message, log: log, type: .info, arg)
    }
    
    @discardableResult public func log<T: Error>(_ error: T) -> T {
        guard enabled else { return error }
        log(dynamic: "\(type(of: error)).\(error): \(error.localizedDescription)")
        return error
    }
    
    @discardableResult public func log(_ error: LocalizedError) -> Error {
        guard enabled else { return error }
        log(dynamic: "\(type(of: error)).\(error): \(error.recoverySuggestion ?? "No recovery suggestion")")
        return error
    }
}
