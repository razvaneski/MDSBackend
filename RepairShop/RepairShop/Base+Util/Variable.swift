//
//  Variable.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import RxSwift

/// The RxSwift Variable is deprecated in the current version.
/// But the concept is rather convenient in some cases so we'll built our own.
///
/// See: https://github.com/ReactiveX/RxSwift/issues/1501
final class Variable<Element> {

    private let subject: BehaviorSubject<Element>

    /// Gets or sets current value of variable.
    ///
    /// Whenever a new value is set, all the observers are notified of the change.
    ///
    /// Even if the newly set value is same as the old value, observers arere still notified for change.
    public var value: Element {
        get {
            return try! subject.value() // swiftlint:disable:this force_try
        }
        set(newValue) {
            subject.on(.next(newValue))
        }
    }

    /// Initializes variable with initial value.
    ///
    /// - parameter value: Initial variable value.
    public init(_ value: Element) {
        subject = BehaviorSubject(value: value)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        return subject
    }

    func subscribeNext(_ onNext: @escaping ((Element) -> Void)) -> Disposable {
        return subject.subscribe(onNext: onNext)
    }

    deinit {
        subject.on(.completed)
    }
}
