//
//  ActionMock.swift
//  TestingPresentableComponentsTests
//
//  Copyright © 2018 Juno. All rights reserved.
//

import Foundation

import ReactiveSwift
import enum Result.NoError

public final class ActionMock<Input, Value, Error: Swift.Error> {

    public typealias Task = SignalProducer<Value, Error>
    public typealias Action = ReactiveSwift.Action<Input, Value, Error>

    public let inputs = MutableProperty<[Input]>([])
    public let pipe = Signal<Signal<Value, Error>.Event, NoError>.pipe()
    public let action: Action

    public init() {
        self.action = Action { [inputs, pipe] input in
            inputs.value.append(input)
            return SignalProducer(pipe.output).dematerialize()
        }
    }

    deinit {
        self.pipe.1.sendCompleted()
    }
}

extension ActionMock {

    public var input: Input! {
        return self.inputs.value.last!
    }

    public var inputsCount: Int {
        return self.inputs.value.count
    }

    public func receive(_ value: Value) {
        self.pipe.input.send(value: .value(value))
        self.pipe.input.send(value: .completed)
    }

    public func receive(_ error: Error) {
        self.pipe.input.send(value: .failed(error))
    }
}
