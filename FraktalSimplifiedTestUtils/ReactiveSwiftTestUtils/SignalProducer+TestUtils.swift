//
//  SignalProducer+TestUtils.swift
//  TestingPresentableComponentsTests
//
//  Copyright © 2018 Juno. All rights reserved.
//

import Foundation

import ReactiveSwift

public final class SignalProducerHistory<Value, Error: Swift.Error> {
    public fileprivate(set) var starting = false
    public fileprivate(set) var started = false
    public fileprivate(set) var events: [Signal<Value, Error>.Event] = []
    public fileprivate(set) var failure: Error?
    public fileprivate(set) var completed = false
    public fileprivate(set) var interrupted = false
    public fileprivate(set) var terminated = false
    public fileprivate(set) var disposed = false
    public fileprivate(set) var values: [Value] = []

    public init() {}
}

extension SignalProducer {
    public typealias History = SignalProducerHistory<Value, Error>
}

extension SignalProducer {

    public func saveHistoryTo(_ history: SignalProducerHistory<Value, Error>) -> SignalProducer {
        return self.on(
            starting: { history.starting = true },
            started: { history.started = true },
            event: { history.events.append($0) },
            failed: { history.failure = $0 },
            completed: { history.completed = true },
            interrupted: { history.interrupted = true },
            terminated: { history.terminated = true },
            disposed: { history.disposed = true },
            value: { history.values.append($0) }
        )
    }
}
