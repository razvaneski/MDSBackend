//
//  LoginController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import UIKit
import RxSwift

class LoginController: BaseController {
    @IBOutlet weak private var usernameTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
    }
    
    private func bindVM() {
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self else { return }
                switch event {
                case .loginSuccess:
                    switch self.viewModel.currentUserInfo.userType {
                    case .repairShop:
                        let vc = instantiateViewController(ofType: RepairshopMainMenuController.self, inStoryboard: .Main)
                        self.navigationController?.pushViewController(vc, animated: true)
                    case .user:
                        let vc = instantiateViewController(ofType: UserMainMenu.self, inStoryboard: .Main)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                case .loginError:
                    self.resetFields()
                }
            }.disposed(by: disposeBag)
        
        viewModel.stateSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] state in
                switch state {
                case .idle:
                    self?.hideLoader()
                case .loading:
                    self?.showLoader()
                }
            }.disposed(by: disposeBag)
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
    }
    
    private func resetFields() {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction private func onEnterPressed() {
        guard let username = usernameTextField.text else {
            showErrorMessage("Please enter username")
            return
        }
        guard let password = passwordTextField.text else {
            showErrorMessage("Please enter password")
            return
        }
        
        viewModel.login(username: username, password: password)
    }
    
    @IBAction private func onSignUpPressed() {
        let vc = instantiateViewController(ofType: SignUpController.self, inStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
