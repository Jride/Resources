//
//  ExecutionGroup.swift
//  Resources
//
//  Created by Josh Rideout on 23/08/2021.
//

import Foundation

/// Used as a replacement for Apples `DispatchGroup`, but handles running code
/// synchronously rather than being returned asynchronously on a specified Queue
public final class ExecutionGroup {
    
    private let dispatchBehaviour: DispatchBehaviour
    private var dispatchGroup: DispatchGroup?
    
    public init() {
        if IS_RUNNING_TEST {
            dispatchBehaviour = .immediately
        } else {
            dispatchGroup = DispatchGroup()
            dispatchBehaviour = .onQueue(.main)
        }
    }
    
    public func enter() {
        dispatchGroup?.enter()
    }
    
    public func leave() {
        dispatchGroup?.leave()
    }
    
    public func wait() {
        dispatchGroup?.wait()
    }
    
    @discardableResult
    public func wait(timeOut: DispatchTime) -> DispatchTimeoutResult? {
        dispatchGroup?.wait(timeout: timeOut)
    }
    
    public func notify(_ handler: @escaping () -> Void) {
        
        switch dispatchBehaviour {
        case .immediately:
            handler()
        case .onQueue(let queue):
            dispatchGroup?.notify(queue: queue) {
                handler()
            }
        }
    }
    
}

public enum DispatchBehaviour {
    case immediately
    case onQueue(DispatchQueue)
    
    public func dispatch(closure: @escaping () -> Void) {
        switch self {
        case .immediately:
            closure()
        case .onQueue(let queue):
            if queue == .main {
                onMainThread {
                    closure()
                }
            } else {
                queue.async {
                    closure()
                }
            }
        }
    }
}

public func onMainThread(work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async {
            work()
        }
    }
}

private let IS_RUNNING_TEST: Bool = {
    NSClassFromString("XCTest") != nil
}()
