//
//  Time.swift
//  Resources
//
//  Created by Josh Rideout on 25/06/2018.
//

import Foundation

public struct Time: Equatable {
    
    public let seconds: Double
    
    public init(seconds: Double) {
        self.seconds = seconds
    }
    
    public init(days: Double) {
        self.seconds = days * 24 * 60 * 60
    }
    
    public init(hours: Double) {
        self.seconds = hours * 60 * 60
    }
    
    public init(minutes: Double) {
        self.seconds = minutes * 60
    }
    
    public init(hours: Double, minutes: Double) {
        self.seconds = hours*60*60 + minutes*60
    }
    
    public init(minutes: Double, seconds: Double) {
        self.seconds = minutes*60 + seconds
    }
    
    public init(hours: Double, minutes: Double, seconds: Double) {
        self.seconds = hours*60*60 + minutes*60 + seconds
    }
}

// MARK: - Computed Time Periods

extension Time {
    public var abs: Time {
        Time(seconds: Swift.abs(seconds))
    }

    public var days: Int {
        return Int(hours/24)
    }
    
    public var hours: Double {
        return seconds / (60 * 60)
    }
    
    public var minutes: Double {
        return seconds / 60
    }
    
    public var milliseconds: Double {
        return seconds * 1000
    }
}

// MARK: - Convenience

extension Time {
    public static let zero = Time(seconds: 0)
}

// MARK: - Operators

public extension Time {
    
    static func + (lhs: Time, rhs: Time) -> Time {
        return Time(seconds: lhs.seconds + rhs.seconds)
    }
    
    static func += (lhs: inout Time, rhs: Time) {
        lhs = Time(seconds: lhs.seconds + rhs.seconds)
    }
    
    static func - (lhs: Time, rhs: Time) -> Time {
        return Time(seconds: lhs.seconds - rhs.seconds)
    }
    
    static func -= (lhs: inout Time, rhs: Time) {
        lhs = Time(seconds: lhs.seconds - rhs.seconds)
    }
}

public extension Time {
    
    static func / (lhs: Time, rhs: Double) -> Time {
        return Time(seconds: lhs.seconds / rhs)
    }
    
    static func * (lhs: Time, rhs: Double) -> Time {
        return Time(seconds: lhs.seconds * rhs)
    }
    
    static func * (lhs: Double, rhs: Time) -> Time {
        return Time(seconds: lhs * rhs.seconds)
    }
}

// MARK: - Comparable

extension Time: Comparable {
    
    public static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.seconds < rhs.seconds
    }
}
