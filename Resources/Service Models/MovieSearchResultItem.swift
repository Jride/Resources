//
//  MovieSearchResultItem.swift
//  Resources
//
//  Created by Josh Rideout on 10/05/2022.
//

import Foundation
import CoreGraphics

struct MovieSearchResultItem {
    
    let id: Int
    let title: String
    let overview: String
}

extension MovieSearchResultItem: Codable {}
