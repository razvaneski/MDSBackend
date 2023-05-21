//
//  SignUpViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import UIKit
import RxSwift

enum SignUpViewModelEvent {
    case goToMainMenu
}

class SignUpViewModel: BaseViewModel<SignUpViewModelEvent> {
    
    func signUp(firstName: String, lastName: String, userName: String, password: String, userType: String) {
        stateSubject.onNext(.loading)
        UserService.shared.signUp(firstName: firstName, lastName: lastName, username: userName, password: password, userType: userType)
            .subscribe(onCompleted: { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.goToMainMenu)
            }, onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }).disposed(by: disposeBag)
    }
}
