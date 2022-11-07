//
//  SingleUseValue.swift
//  Resources
//
//  Created by Josh Rideout on 01/11/2019.
//

import Foundation

public class SingleUseValue<T> {
    private var value: T?
    
    public var isConsumed: Bool {
        return value != nil
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func get() -> T? {
        let v = value
        value = nil
        return v
    }
}
