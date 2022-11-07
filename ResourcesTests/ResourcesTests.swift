//
//  ResourcesTests.swift
//  ResourcesTests
//
//  Created by Josh Rideout on 01/09/2022.
//

import XCTest
@testable import Resources

class MockFeedManager: FeedManager {
    
    enum Behaviour {
        case succeed
        case fail(Error)
    }
    
    var behaviour = Behaviour.succeed
    var returnedError: Error?
    
    func resolve(resources: [AnyManagedResource], completion: @escaping GenericFetchCompletionBlock) {
        
        switch behaviour {
        case .succeed:
            
            for resource in resources where resource.isActive {
                resource.fetch { [weak self] result in
                    if let error = result.error, resource.isRequired {
                        self?.returnedError = error
                        completion(error)
                    }
                }
            }
            
        case .fail(let error):
            
            returnedError = error
            completion(error)
            
        }
        
    }
    
}

class ResourcesTests: XCTestCase {
    
    enum MovieTestError: Error, Equatable {
        case forcedError
    }

    private var sut: MovieDatasource!
    private var mockFeedManager = MockFeedManager()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = MovieDatasource(feedManager: mockFeedManager)
    }
    
    func test_WhenFeedManagerThrowsError_ThenDatasourceThrowsError() {
        
        mockFeedManager.behaviour = .fail(MovieTestError.forcedError)
        
        sut.fetchMovieDetails(forQuery: "unknown movie") { result in
            XCTAssertEqual((result.error as? MovieTestError), MovieTestError.forcedError)
        }
        
    }

}
