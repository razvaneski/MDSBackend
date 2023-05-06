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
            .subscribe { [weak self] event in // TODO: go to next screensa
                switch event {
                case .goToLogin:
                    break
                case .goToMainMenu:
                    break
                }
            }.disposed(by: disposeBag)
    }
}

