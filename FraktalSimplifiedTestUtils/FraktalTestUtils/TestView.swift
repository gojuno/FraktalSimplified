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

public protocol TestPresenterProtocol {
    associatedtype TestView: TestViewType
    var presenter: Presenter<TestView.ViewModel> { get }
    var presented: [PresentedValue<TestView>] { get }
}

extension TestPresenterProtocol {
    public var last: TestView! { return self.presented.last?.value }
}

public final class TestPresenter<TestView: TestViewType>: TestPresenterProtocol {

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
