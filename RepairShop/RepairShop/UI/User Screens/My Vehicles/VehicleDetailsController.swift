//
//  VehicleDetailsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import UIKit
import RxSwift

class VehicleDetailsController: BaseController {
    @IBOutlet weak private var makeTextField: UITextField!
    @IBOutlet weak private var modelTextField: UITextField!
    @IBOutlet weak private var yearTextField: UITextField!
    @IBOutlet weak private var vinTextField: UITextField!
    @IBOutlet weak private var licensePlateTextField: UITextField!
    @IBOutlet weak private var saveButton: UIButton!
    
    private var viewModel: VehicleDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
        
        makeTextField.delegate = self
        modelTextField.delegate = self
        yearTextField.delegate = self
        vinTextField.delegate = self
        licensePlateTextField.delegate = self
    }
    
    func configure(vehicleId: String) {
        self.viewModel = VehicleDetailsViewModel(id: vehicleId)
    }
    
    private func bindVM() {
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .updateSuccess:
                    self?.showSuccessMessage("Vehicle updated successfully.")
                }
            }.disposed(by: disposeBag)
        
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
            .subscribe(onNext: { [weak self] error in
                self?.handleError(error: error)
            }).disposed(by: disposeBag)
        
        viewModel.vehicle
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] vehicle in
                guard let vehicle else {
                    self?.makeTextField.superview?.isHidden = true
                    return
                }
                self?.makeTextField.superview?.isHidden = false
                self?.configureUI(vehicle: vehicle)
            }).disposed(by: disposeBag)
    }

    private func configureUI(vehicle: Vehicle) {
        self.makeTextField.text = vehicle.make
        self.modelTextField.text = vehicle.model
        self.yearTextField.text = String(vehicle.year)
        self.vinTextField.text = vehicle.vin
        self.licensePlateTextField.text = vehicle.licensePlate
        
        checkFields()
    }
    
    private func checkFields() {
        guard let vehicle = viewModel.vehicle.value else {
            saveButton.isHidden = true
            return
        }
        if makeTextField.text != vehicle.make
            || modelTextField.text != vehicle.model
            || yearTextField.text != String(vehicle.model)
            || vinTextField.text != vehicle.vin
            || licensePlateTextField.text != vehicle.licensePlate {
            saveButton.isHidden = false
            return
        }
        saveButton.isHidden = true
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onSavePressed() {
        guard let make = makeTextField.text,
                let model = modelTextField.text,
                let year = Int(yearTextField.text ?? ""),
                let vin = vinTextField.text,
                let licensePlate = licensePlateTextField.text else {
            self.showErrorMessage("Some fields are invalid")
            return
        }
        guard !make.isEmpty else {
            showErrorMessage("Make cannot be empty")
            return
        }
        guard !model.isEmpty else {
            showErrorMessage("Model cannot be empty")
            return
        }
        guard 1900 < year && year < 2024 else {
            showErrorMessage("Year is invalid")
            return
        }
        viewModel.updateVehicle(make: make, model: model, year: year, vin: vin, licensePlate: licensePlate)
    }
}

extension VehicleDetailsController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkFields()
    }
}
