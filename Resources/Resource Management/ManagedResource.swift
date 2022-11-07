//
//  ManagedResource.swift
//  Resources
//
//  Created by Josh Rideout on 03/12/2020.
//

import Foundation

public class ManagedResource<T> {
    
    public typealias ResourceResult = Result<T, Error>
    
    private let resource: Resource<T>
    fileprivate(set) public var isActive = false
    fileprivate(set) public var isRequired = false
    
    public var result: ResourceResult {
        return resource.result
    }
    
    private let invalidateClosure: () -> Void
    
    public init(resource: Resource<T>) {
        self.resource = resource
        self.invalidateClosure = resource.invalidate
    }
    
    public func prefetch() {
        resource.prefetch()
    }
    
    public func fetch(completion: @escaping (ResourceResult) -> Void) {
        resource.fetch(completion: completion)
    }
    
    public func invalidate() {
        self.invalidateClosure()
    }
    
    public func set(active: Bool, required: Bool) {
        self.isActive = active
        self.isRequired = required
    }
    
    public func valid(for timePeriod: Time) {
        resource.setCacheExpiration(.after(timePeriod, fromDate: .now), shouldForceUpdate: false)
    }
}

// This class purely exists to erase the use of Generics which then allows us to
// construct an Array of managed resources
public class AnyManagedResource {
    
    private let fetchClosure: (@escaping (Result<Any, Error>) -> Void) -> Void

    private let getIsActiveClosure: () -> Bool
    private let setIsActiveClosure: (Bool) -> Void
    public var isActive: Bool {
        get { self.getIsActiveClosure() }
        set { self.setIsActiveClosure(newValue) }
    }
    
    private let getIsRequiredClosure: () -> Bool
    private let setIsRequiredClosure: (Bool) -> Void
    public var isRequired: Bool {
        get { getIsRequiredClosure() }
        set { setIsRequiredClosure(newValue) }
    }
    
    private let invalidateClosure: () -> Void
    
    public init<T>(resource: ManagedResource<T>) {
        self.fetchClosure = { completion in
            resource.fetch { (result) in
                completion(result.map { $0 as Any })
            }
        }
        
        self.getIsActiveClosure = { resource.isActive }
        self.setIsActiveClosure = { resource.isActive = $0 }
        
        self.getIsRequiredClosure = { resource.isRequired }
        self.setIsRequiredClosure = { resource.isRequired = $0 }
        
        self.invalidateClosure = resource.invalidate
    }
    
    public func fetch(completion: @escaping (Result<Any, Error>) -> Void) {
        fetchClosure(completion)
    }
    
    public func invalidate() {
        self.invalidateClosure()
    }
    
}

// MARK: - RemoteResouce -> ManagedResource

extension Resource {
    public func managed() -> ManagedResource<T> {
        return ManagedResource(resource: self)
    }
}

// MARK: - ManagedResource -> AnyManagedResource

extension ManagedResource {
    public func asAnyManagedResource() -> AnyManagedResource {
        return AnyManagedResource(resource: self)
    }
}
