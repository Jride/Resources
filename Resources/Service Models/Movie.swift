//
//  Movie.swift
//  Resources
//
//  Created by Josh Rideout on 03/09/2022.
//

import Foundation

struct Movie: Equatable {
    
    let id: Int
    let title: String
    let status: String
    let tagline: String?
    let runtime: Int
    let budget: Int
    let revenue: Int
}

extension Movie: Codable {}
