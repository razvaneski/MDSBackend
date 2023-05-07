//
//  BaseViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import RxSwift

enum ViewModelState {
    case loading
    case idle
}

class BaseViewModel<T> {
    let eventSubject = PublishSubject<T>()
    let stateSubject = PublishSubject<ViewModelState>()
    let errorSubject = PublishSubject<Error>()
    let disposeBag = DisposeBag()
    
    var currentUserInfo: UserInfo {
        return UserService.shared.currentUserInfo
    }
}
