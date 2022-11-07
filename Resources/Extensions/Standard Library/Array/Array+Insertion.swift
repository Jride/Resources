//
//  Array+Insertion.swift
//  Resources
//
//  Created by Josh Rideout on 25/06/2018.
//

import Foundation

extension Array {
    
    public func appending(_ item: Element) -> [Element] {
        var newArray = self
        newArray.append(item)
        return newArray
    }
}
