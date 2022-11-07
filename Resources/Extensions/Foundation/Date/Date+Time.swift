//
//  Date+Time.swift
//  Resources
//
//  Created by Josh Rideout on 08/03/2022.
//

import Foundation

extension Date {
    /// Creates a new date value by adding the `Time` object to this date.
    public func adding(_ time: Time) -> Date {
        return self.addingTimeInterval(time.seconds)
    }
}
