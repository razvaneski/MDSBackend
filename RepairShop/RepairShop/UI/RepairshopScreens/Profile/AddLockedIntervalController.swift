//
//  AddLockedIntervalController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 05.06.2023.
//

import UIKit
import RxSwift

class AddLockedIntervalController: BaseController {
    @IBOutlet weak private var startDatePicker: UIDatePicker!
    @IBOutlet weak private var endDatePicker: UIDatePicker!
    
    var viewModel: RepairshopProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
    }
    
    private func bindVM() {
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .addIntervalSuccess:
                    self?.showSuccessMessage("Interval added successfully.")
                    self?.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            }.disposed(by: disposeBag)
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
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
    }
    
    @IBAction private func onAddPressed() {
        viewModel.addLockedInterval(startDate: startDatePicker.date, endDate: endDatePicker.date)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
