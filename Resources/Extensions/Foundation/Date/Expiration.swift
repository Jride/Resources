//
//  Expiration.swift
//  Resources
//
//  Created by Josh Rideout on 08/03/2022.
//

import Foundation

/// This allows an expiration to be set and queried.
public enum Expiration {
    case never
    case after(Time, fromDate: Date = .now)
    case afterDate(Date)
}

// MARK: - Properties

extension Expiration {
    /// The current expiration date, or nil if one is not set.
    public var expirationDate: Date? {
        switch self {
        case .never: return nil
        case .after(let timePeriod, let startDate): return startDate.adding(timePeriod)
        case .afterDate(let date): return date
        }
    }
    
    public var neverExpires: Bool {
        switch self {
        case .never: return true
        case .after, .afterDate: return false
        }
    }
    
    public var hasExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return Date() > expirationDate
    }
        
    public var hasNotExpired: Bool { return !hasExpired }
}
