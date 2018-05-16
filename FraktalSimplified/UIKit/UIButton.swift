//
//  UIButton.swift
//  TestingPresentableComponents
//
//  Copyright © 2018 Juno. All rights reserved.
//

import Foundation
import UIKit

import ReactiveSwift

extension UIButton {
    
    public var simpleActionPresenter: Presenter<() -> Void> {
        return Presenter.UI { [weak self] action in
            guard let someSelf = self else { return nil }
            let target = Target {
                if someSelf.isEnabled { action() }
            }
            someSelf.addTarget(target, action: Target.ActionSelector, for: .touchUpInside)
            return ScopedDisposable(AnyDisposable {
                someSelf.removeTarget(target, action: Target.ActionSelector, for: .touchUpInside)
            })
        }
    }

    public var actionViewModelPresenter: Presenter<AnyPresentable<ActionViewModelPresenters>> {
        return Presenter.UI { [weak self] presentable in
            guard let someSelf = self else { return nil }
            return presentable.present(ActionViewModelPresenters(
                simpleAction: someSelf.simpleActionPresenter,
                executing: Presenter.UI { _ in nil },
                enabled: someSelf.enabledPresenter
            ))
        }
    }

    public var titlePresenter: Presenter<String> {
        return Presenter.UI { [weak self] in
            self?.setTitle($0, for: .normal)
            return nil
        }
    }

    public var enabledPresenter: Presenter<Bool> {
        return Presenter.UI { [weak self] in
            self?.isEnabled = $0
            return nil
        }
    }
}

class Target: NSObject {

    static var ActionSelector = #selector(performAction)

    init(action: @escaping () -> Void) {
        self.action = action
        super.init()
    }

    private let action: () -> Void
    @objc func performAction() { self.action() }
}

public struct ActionViewModelPresenters {
    public let simpleAction: Presenter<() -> Void>
    public let executing: Presenter<Bool>
    public let enabled: Presenter<Bool>

    public init(
        simpleAction: Presenter<() -> Void>,
        executing: Presenter<Bool>,
        enabled: Presenter<Bool>
    ) {
        self.simpleAction = simpleAction
        self.executing = executing
        self.enabled = enabled
    }
}
