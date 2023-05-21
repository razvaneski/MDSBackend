//
//  AddVehicleController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import UIKit
import RxSwift

enum AddVehicleViewModelEvent {
    case addSuccess
}

class AddVehicleViewModel: BaseViewModel<AddVehicleViewModelEvent> {
    func addVehicle(vin: String, licensePlate: String, make: String, model: String, year: Int) {
        stateSubject.onNext(.loading)
        VehiclesService.shared.addVehicle(vin: vin, licensePlate: licensePlate, make: make, model: model, year: year)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.addSuccess)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)

    }
}

class AddVehicleController: BaseController {
    @IBOutlet weak private var makeTextField: UITextField!
    @IBOutlet weak private var modelTextField: UITextField!
    @IBOutlet weak private var yearTextField: UITextField!
    @IBOutlet weak private var vinTextField: UITextField!
    @IBOutlet weak private var licensePlateTextField: UITextField!
    
    private var viewModel: AddVehicleViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = AddVehicleViewModel()
        bindVM()
    }
    
    private func bindVM() {
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
        
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .addSuccess:
                    self?.showSuccessMessage("Added successfully.")
                    self?.navigationController?.popViewController(animated: true)
                }
            }.disposed(by: disposeBag)

        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
    }
    
    private func checkFields() -> Bool {
        guard let make = makeTextField.text,
              let model = modelTextField.text,
              let year = Int(yearTextField.text ?? "") else {
            showErrorMessage("Some fields are invalid.")
            return false
        }
        guard !make.isEmpty else {
            showErrorMessage("Make cannot be empty")
            return false
        }
        guard !model.isEmpty else {
            showErrorMessage("Model cannot be empty")
            return false
        }
        guard 1900 < year && year < 2024 else {
            showErrorMessage("Year is invalid")
            return false
        }
        return true
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onAddPressed() {
        if checkFields() {
            let make = makeTextField.text!
            let model = modelTextField.text!
            let year = Int(yearTextField.text!)!
            let vin = vinTextField.text ?? ""
            let licensePlate = licensePlateTextField.text ?? ""
            viewModel.addVehicle(vin: vin, licensePlate: licensePlate, make: make, model: model, year: year)
        }
    }
}
