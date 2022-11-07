//
//  FeedManager.swift
//  Resources
//
//  Created by Josh Rideout on 03/12/2020.
//

import Foundation

public typealias GenericFetchCompletionBlock = (_ error: Error?) -> Void

public protocol FeedManager {
    func resolve(resources: [AnyManagedResource], completion: @escaping GenericFetchCompletionBlock)
}

public class FeedManagerImpl: FeedManager {
    
    public init() {}

    public func resolve(resources: [AnyManagedResource], completion: @escaping (_ error: Error?) -> Void) {
        
        let completionHandler = SingleUseValue(completion)
        
        let executionGroup = ExecutionGroup()
        
        for resource in resources where resource.isActive {
            executionGroup.enter()
            resource.fetch { (result) in
                if let error = result.error, resource.isRequired {
                    completionHandler.get()?(error)
                }
                executionGroup.leave()
            }
        }
        
        executionGroup.notify {
            // All the feeds finished fetching their content
            completionHandler.get()?(nil)
        }
    }
    
}
