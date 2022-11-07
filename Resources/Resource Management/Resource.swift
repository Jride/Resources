//
//  Resource.swift
//  Resources
//
//  Created by Josh Rideout on 03/12/2020.
//

import Foundation

public enum ResourceError: Error {
    case fetchNotTriggered
    case generic
}

public final class Resource<T> {
    
    public typealias ResourceResult = Result<T, Error>
    public typealias AsyncBlock = (@escaping (ResourceResult) -> Void) -> Void
    
    public var result: ResourceResult { fetchingCoordinator.result }
    private var fetchingCoordinator = ResourceFetchingCoordinator(
        initialResult: ResourceResult.failure(ResourceError.fetchNotTriggered),
        isResultSuccess: { $0.isSuccess }
    )
    
    private var cacheExpiration: Expiration = .never
    private let fetchClosure: AsyncBlock
    private var invalidateChainedResource: (() -> Void)?
    
    private init(fetchClosure: @escaping AsyncBlock) {
        self.fetchClosure = fetchClosure
    }
    
    public func prefetch() {
        fetch { _ in }
    }
    
    public func fetch(completion: @escaping (ResourceResult) -> Void) {
        checkCacheIsStillValid()
        let wasIdleBeforeIncomingRequest = fetchingCoordinator.isIdle
        fetchingCoordinator.appendIncomingRequest(completion: completion)
        
        guard wasIdleBeforeIncomingRequest else {
            // We're in the middle of fetching the previous request so we should bail here
            return
        }
        
        guard fetchingCoordinator.isCachedResultAFailure else {
            // If we already have a successfully cached result then we should just return that
            fetchingCoordinator.callStoredCallbacksWithCachedResult()
            return
        }
        
        func completionHandler(_ resourceResult: ResourceResult) {
            fetchingCoordinator.updateCachedResult(resourceResult)
            fetchingCoordinator.callStoredCallbacksWithCachedResult()
        }
        
        fetchClosure(completionHandler)
    }
}

// MARK: - Cache Handling

extension Resource {
    public func invalidate() {
        fetchingCoordinator.invalidateCachedResult()
        invalidateChainedResource?()
    }
    
    /// Sets the cache expiration. If `shouldForceUpdate` is not true, updates will not be allowed until the current cache expires.
    func setCacheExpiration(_ expiration: Expiration, shouldForceUpdate: Bool) {
        guard cacheExpiration.neverExpires || cacheExpiration.hasExpired || shouldForceUpdate else { return }
        self.cacheExpiration = expiration
    }
    
    private func checkCacheIsStillValid() {
        if cacheExpiration.hasExpired {
            invalidate()
        }
    }
}

// MARK: - Convenience initialisers

extension Resource {
    
    public convenience init(constant: T) {
        self.init() { (completion) in
            completion(.success(constant))
        }
    }
    
    public convenience init(async fetchBlock: @escaping AsyncBlock) {
        self.init(fetchClosure: fetchBlock)
    }
    
    public convenience init(request: @escaping () -> URLRequest, parse: @escaping (Data) -> T?) {
        self.init(networkService: NetworkServiceImpl(), request: request, parse: parse)
    }
    
    public convenience init<A, B>(_ resourceA: Resource<A>, _ resourceB: Resource<B>) where T == (A, B) {
        
        var completionWasCalled = false
        
        self.init(
            fetchClosure: { completion in
                
                func completionHandler(_ result: Result<(A, B), Error>) {
                    guard completionWasCalled == false else { return }
                    completion(result)
                    completionWasCalled = true
                }
                
                var fetchedResultA: A?
                var fetchedResultB: B?
                
                func fetchCompleted() {
                    guard let resultA = fetchedResultA,
                          let resultB = fetchedResultB else {
                        return
                    }
                    
                    completionHandler(.success((resultA, resultB)))
                }
                
                resourceA.fetch { (result) in
                    switch result {
                    case .failure(let error):
                        completionHandler(.failure(error))
                    case .success(let resultA):
                        fetchedResultA = resultA
                    }
                    fetchCompleted()
                }
                
                resourceB.fetch { (result) in
                    switch result {
                    case .failure(let error):
                        completionHandler(.failure(error))
                    case .success(let resultB):
                        fetchedResultB = resultB
                    }
                    fetchCompleted()
                }
                
            })
        
    }
    
    convenience init (networkService: NetworkService, request: @escaping () -> URLRequest, parse: @escaping (Data) -> T?) {
        
        self.init(
            fetchClosure: { completion in
                
                networkService.get(request: request()) { (result) in
                    
                    switch result {
                    case .success(let data):
                        if let value = parse(data) {
                            completion(.success(value))
                        } else {
                            completion(.failure(ResourceError.generic))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            }
        )
    }
    
    private convenience init<DependantResult>(chained first: Resource<DependantResult>,
                                              then second: DependantResource<DependantResult, T>) {
        
        let block: AsyncBlock = { completion in
            
            first.fetch(completion: { firstOutput in
                
                switch firstOutput {
                case .success(let firstOutputResult):
                    
                    second.fetch(
                        input: firstOutputResult,
                        completion: completion
                    )
                    
                case .failure(let error):
                    
                    onMainThread {
                        completion(.failure(error))
                    }
                    
                }
                
            })
        }
        
        self.init(fetchClosure: block)
        self.invalidateChainedResource = { first.invalidate() }
    }
    
}

// MARK: - Mapping/Chaining Resources

extension Resource {
    
    public func map<Output>(_ mapToNewResource: @escaping (T) -> Output) -> Resource<Output> {
        return then(DependantResource(map: mapToNewResource))
    }
    
    public func mapResult<Output>(_ mapToNewResource: @escaping (T) -> Result<Output, Error>) -> Resource<Output> {
        return then(DependantResource(mapResult: mapToNewResource))
    }
    
    public func then<Output>(_ other: DependantResource<T, Output>) -> Resource<Output> {
        return Resource<Output>(chained: self, then: other)
    }
    
}
