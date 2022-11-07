//
//  ResourceFetchingCoordinator.swift
//  Resources
//
//  Created by Josh Rideout on 04/12/2020.
//

import Foundation

struct ResourceFetchingCoordinator<T> {
    
    struct Callback {
        let callback: (T) -> Void
    }
    
    enum State {
        case idle
        case fetching([Callback])
        
        var isIdle: Bool {
            switch self {
            case .idle: return true
            default: return false
            }
        }
        
        var isFetching: Bool {
            switch self {
            case .fetching: return true
            default: return false
            }
        }
        
        var callbacks: [Callback] {
            switch self {
            case .idle: return []
            case .fetching(let callbacks): return callbacks
            }
        }
    }
    
    private var state = State.idle
    private(set) var result: T
    private let initialResult: T
    private let isResultSuccess: (T) -> Bool
    
    init(initialResult: T, isResultSuccess: @escaping (T) -> Bool) {
        self.result = initialResult
        self.initialResult = initialResult
        self.isResultSuccess = isResultSuccess
    }
    
    var isIdle: Bool {
        state.isIdle
    }
    
    var isCachedResultAFailure: Bool {
        isResultSuccess(result) == false
    }
    
    mutating func appendIncomingRequest(completion: @escaping (T) -> Void) {
        // Store the callback and return if we're already fetching
        let cb = Callback(callback: completion)
        switch self.state {
        case .fetching(let callbacks):
            self.state = .fetching(callbacks.appending(cb))
        case .idle:
            self.state = .fetching([cb])
        }
    }
    
    mutating func updateCachedResult(_ result: T) {
        self.result = result
    }
    
    mutating func invalidateCachedResult() {
        self.result = initialResult
    }
    
    mutating func callStoredCallbacksWithCachedResult() {
        let result = self.result
        for cb in state.callbacks {
            onMainThread {
                cb.callback(result)
            }
        }
        self.state = .idle
    }
}
