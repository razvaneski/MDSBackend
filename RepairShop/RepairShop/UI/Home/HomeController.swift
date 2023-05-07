//
//  HomeController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 24.04.2023.
//

import UIKit
import RxSwift

class HomeController: BaseController {
    private let viewModel = HomeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: remove this (testing without autologin)
        let localStorage = LocalStorage()
        localStorage.setString("", key: .userToken)
        
        bindVM()
        
        viewModel.getUserInfo()
    }
    
    private func bindVM() {
        viewModel.stateSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle:
                    self?.hideLoader()
                case .loading:
                    self?.showLoader()
                }
            }).disposed(by: disposeBag)
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
        
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self else { return }
                switch event {
                case .goToLogin:
                    let vc = instantiateViewController(ofType: LoginController.self, inStoryboard: .Main)
                    self.navigationController?.pushViewController(vc, animated: true)
                case .goToMainMenu:
                    switch self.viewModel.currentUserInfo.userType {
                    case .user:
                        let vc = instantiateViewController(ofType: UserMainMenu.self, inStoryboard: .Main)
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .repairShop:
                        break // TODO
                    case .admin:
                        break // TODO
                    }
                }
            }.disposed(by: disposeBag)
    }
}
