//
//  DependantResource.swift
//  Resources
//
//  Created by Josh Rideout on 04/12/2020.
//

import Foundation

public final class DependantResource<Input, Output> {
    
    public typealias ResourceResult = Result<Output, Error>
    public typealias AsyncBlock = (Input, @escaping (ResourceResult) -> Void) -> Void
    
    private let fetchClosure: AsyncBlock
    
    init(fetchClosure: @escaping AsyncBlock) {
        self.fetchClosure = fetchClosure
    }
    
    public func fetch(input: Input, completion: @escaping (ResourceResult) -> Void) {
        fetchClosure(input, completion)
    }
}

extension DependantResource {
    
    public convenience init(request: @escaping (Input) -> URLRequest, parse: @escaping (Data) -> Output?) {
        self.init(networkService: NetworkServiceImpl(), request: request, parse: parse)
    }
    
    public convenience init(map: @escaping (Input) -> Output) {
        self.init(
            fetchClosure: { input, completion in
                completion(.success(map(input)))
            }
        )
    }
    
    public convenience init(mapResult: @escaping (Input) -> ResourceResult) {
        self.init(
            fetchClosure: { input, completion in
                completion(mapResult(input))
            }
        )
    }
    
    public convenience init(async fetchBlock: @escaping AsyncBlock) {
        self.init(
            fetchClosure: fetchBlock
        )
    }
    
    convenience init(networkService: NetworkService, request: @escaping (Input) -> URLRequest, parse: @escaping (Data) -> Output?) {
        
        self.init(
            fetchClosure: { input, completion in
                
                networkService.get(request: request(input)) { (result) in
                    
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
                
            })
    }
}
