//
//  NetworkService.swift
//  Resources
//
//  Created by Josh Rideout on 10/08/2019.
//

import Foundation

public enum NetworkServiceError: Error {
    case invalidRequest
    case urlSessionError(Error)
    case invalidHttpStatus(Int)
    case emptyResponse
    case invalidResponse
    case unknown
}

public protocol NetworkService {
    @discardableResult
    func get(request: URLRequest, completion: @escaping (Result<Data, NetworkServiceError>) -> Void) -> URLSessionDataTask
}

public class NetworkServiceImpl: NetworkService {
    
    public init() {}
    
    @discardableResult
    public func get(request: URLRequest, completion: @escaping (Result<Data, NetworkServiceError>) -> Void) -> URLSessionDataTask {
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                onMainThread {
                    completion(.failure(.urlSessionError(error)))
                }
                return
            }
            
            guard let httpURLResponse = response as? HTTPURLResponse else {
                onMainThread {
                    completion(.failure(.unknown))
                }
                return
            }
            
            guard (200..<300).contains(httpURLResponse.statusCode) else {
                onMainThread {
                    completion(.failure(.invalidHttpStatus(httpURLResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                onMainThread {

                    completion(.failure(.emptyResponse))
                }
                return
            }
            
            onMainThread {
                completion(.success(data))
            }
        }
        
        dataTask.resume()
        
        return dataTask
    }
}
