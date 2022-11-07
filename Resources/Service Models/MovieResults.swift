//
//  MovieResults.swift
//  Resources
//
//  Created by Josh Rideout on 10/05/2022.
//

import Foundation

enum MovieResultsError: Error {
    case noResults
}

struct MovieResults {
    
    let total_results: Int
    let results: [MovieSearchResultItem]
    
}

extension MovieResults: Codable {}
