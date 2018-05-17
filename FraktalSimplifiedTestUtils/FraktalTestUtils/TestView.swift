//
//  TestView.swift
//  TestingPresentableComponentsTests
//
//  Copyright © 2018 Juno. All rights reserved.
//

import Foundation
import ReactiveSwift
import FraktalSimplified

public protocol TestViewType {
    associatedtype ViewModel
    init(_ viewModel: ViewModel)
    var disposable: ScopedDisposable<AnyDisposable>? { get }
}

public final class TestPresenter<TestView: TestViewType> {

    public init() {}

    public var presenter: Presenter<TestView.ViewModel> {
        return Presenter.Test { [weak self] presentable in
            let view = TestView(presentable)
            let presentedValue = PresentedValue(value: view)
            presentedValue.disposable += presentedValue.value.disposable
            self!.presented.append(presentedValue)
            return presentedValue.disposable
        }
    }

    public private(set) var presented: [PresentedValue<TestView>] = []
    public var last: TestView! { return self.presented.last?.value }
}

extension TestViewType {
    // TODO: Consider using 'TestPresenter' name
    public typealias View = TestPresenter<Self>
}

public final class OptionalTestView<WrappedTestView: TestViewType>: TestViewType {

    public let view: WrappedTestView?

    public var disposable: ScopedDisposable<AnyDisposable>? {
        return self.view?.disposable
    }

    public init(_ viewModel: WrappedTestView.ViewModel?) {
        self.view = viewModel.map(WrappedTestView.init)
    }
}

extension TestViewType {
    public typealias Optional = OptionalTestView<Self>
}

public final class AnyTestView<Value>: TestViewType {

    public let value: Value
    public var disposable: ScopedDisposable<AnyDisposable>? { return nil }

    public init(_ viewModel: Value) {
        self.value = viewModel
    }
}
