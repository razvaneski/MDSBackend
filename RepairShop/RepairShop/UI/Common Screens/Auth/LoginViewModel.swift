//
//  LoginViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import RxSwift

enum LoginViewModelEvent {
    case loginSuccess
    case loginError
}

class LoginViewModel: BaseViewModel<LoginViewModelEvent> {
    
    func login(username: String, password: String) {
        stateSubject.onNext(.loading)
        UserService.shared.login(username: username, password: password)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.loginSuccess)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
                self?.eventSubject.onNext(.loginError)
            }.disposed(by: disposeBag)
    }
}
