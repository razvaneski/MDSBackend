//
//  SignUpController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import UIKit
import RxSwift

class SignUpController: BaseController {
    @IBOutlet weak private var firstNameTextField: UITextField!
    @IBOutlet weak private var lastNameTextField: UITextField!
    @IBOutlet weak private var usernameTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var confirmPasswordTextField: UITextField!
    @IBOutlet weak private var userTypeSegmentedControl: UISegmentedControl!
    
    private let viewModel = SignUpViewModel()
    
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
                case .goToMainMenu: // TODO: Go to main menu
                    switch self.viewModel.currentUserInfo.userType {
                    case .admin:
                        break
                    case .repairShop:
                        break
                    case .user:
                        let vc = instantiateViewController(ofType: UserMainMenu.self, inStoryboard: .Main)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }.disposed(by: disposeBag)
        
        viewModel.stateSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] state in
                switch state {
                case .loading:
                    self?.showLoader()
                case .idle:
                    self?.hideLoader()
                }
            }.disposed(by: disposeBag)
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onConfirmPressed() {
        guard let firstName = firstNameTextField.text else {
            showErrorMessage("Please enter first name")
            return
        }
        guard let lastName = lastNameTextField.text else {
            showErrorMessage("Please enter last name")
            return
        }
        guard let username = usernameTextField.text else {
            showErrorMessage("Please enter username")
            return
        }
        guard let password = passwordTextField.text else {
            showErrorMessage("Please enter password")
            return
        }
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            showErrorMessage("Passwords do not match")
            return
        }
        
        let userType = userTypeSegmentedControl.selectedSegmentIndex == 0 ? "user" : "repairshop"
        
        viewModel.signUp(firstName: firstName, lastName: lastName, userName: username, password: password, userType: userType)
    }
}
