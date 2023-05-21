//
//  HomeViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import Foundation
import RxSwift

enum HomeViewModelEvent {
    case goToLogin
    case goToMainMenu
}

class HomeViewModel: BaseViewModel<HomeViewModelEvent> {
    func getUserInfo() {
        stateSubject.onNext(.loading)
        UserService.shared.getUserInfo()
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.goToMainMenu)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
                self?.eventSubject.onNext(.goToLogin)
            }.disposed(by: disposeBag)
    }
}
