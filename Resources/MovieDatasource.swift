//
//  MovieDatasource.swift
//  Resources
//
//  Created by Josh Rideout on 06/09/2022.
//

import Foundation

class MovieDatasource {
    
    private let logger = UnifiedLogger(category: "Movie Search")
    private let feedManager: FeedManager
    
    convenience init() {
        self.init(feedManager: FeedManagerImpl())
    }
    
    init(feedManager: FeedManager) {
        self.feedManager = feedManager
    }
    
    func fetchMovieDetails(forQuery query: String, completion: @escaping (Result<Movie, Error>) -> Void) {
            
        let queryResource = Resource(constant: query)
        
        // The resource for fetching the movie search results
        let movieSearchResultResource: DependantResource<String, MovieResults> = DependantResource { result in
            searchURLRequest(withQuery: result)
        } parse: { data in
            try? JSONDecoder().decode(MovieResults.self, from: data)
        }
        
        // The dependant resource that returns the first search result item
        let firstMovieSearchResultItemResource: DependantResource<MovieResults, MovieSearchResultItem> =
        DependantResource(mapResult: { response in
            guard let topResult = response.results.first else {
                return .failure(MovieResultsError.noResults)
            }
            
            return .success(topResult)
        })
        
        // Another dependant resource that fetches the movie details of the search item
        let movieDetailsResource: DependantResource<MovieSearchResultItem, Movie> =
        DependantResource { response in
            movieDetailsURLRequest(withMovieID: String(response.id))
        } parse: { data in
            try? JSONDecoder().decode(Movie.self, from: data)
        }
        
        // Chain the resources together
        let movieSearchResource = queryResource
            .then(movieSearchResultResource)
            .then(firstMovieSearchResultItemResource)
            .then(movieDetailsResource)
            .managed()
        
        // Activate the resource and mark it required
        movieSearchResource.set(active: true, required: true)
        
        // Resolves all the resources (in this case there is just the one)
        feedManager.resolve(resources: [movieSearchResource.asAnyManagedResource()]) { [weak self] error in
            guard let self = self else { return }
            
            if let feedError = error {
                self.logger.log("Feed manager failed to resolve the feeds: %{public}@", "\(feedError.localizedDescription)")
                completion(.failure(feedError))
                return
            }

            self.logger.log("Feed manager successfully resolved the feeds!")
            if let result = try? movieSearchResource.result.get() {
                completion(.success(result))
            } else {
                completion(.failure(MovieResultsError.noResults))
            }
        }
        
    }
    
}

// MARK: - URLRequest Helpers

private let apikey = "f76ee475d7f088e44f59726d1f6d870b"

private func searchURLRequest(withQuery query: String) -> URLRequest {
    
    var urlComp = URLComponents(string: "https://api.themoviedb.org/3/search/movie")!
    urlComp.queryItems = [
        .init(name: "api_key", value: apikey),
        .init(name: "query", value: query.replacingOccurrences(of: " ", with: "+"))
    ]
    
    guard let url = urlComp.url else {
        fatalError("Unable to construct the url")
    }
    
    return URLRequest(url: url)
}

private func movieDetailsURLRequest(withMovieID movieId: String) -> URLRequest {
    
    var urlComp = URLComponents(string: "https://api.themoviedb.org/3/movie/\(movieId)")!
    
    urlComp.queryItems = [
        .init(name: "api_key", value: "f76ee475d7f088e44f59726d1f6d870b")
    ]
    
    guard let url = urlComp.url else {
        fatalError("Unable to construct the url")
    }
    
    return URLRequest(url: url)
    
}
