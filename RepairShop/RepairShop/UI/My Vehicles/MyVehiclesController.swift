//
//  MyVehiclesController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import UIKit
import RxSwift

class VehicleTableViewCell: UITableViewCell {
    @IBOutlet weak private var titleLabel: UILabel!
    
    func configure(title: String) {
        self.titleLabel.text = title
    }
}

class MyVehiclesController: BaseController {
    @IBOutlet weak private var tableView: UITableView!
    
    private let viewModel = MyVehiclesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
    }
    
    private func bindVM() {
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                
            }).disposed(by: disposeBag)
        
        viewModel.vehicles
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.handleError(error: error)
            }).disposed(by: disposeBag)
        
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
    }
    
    @IBAction private func onAddVehiclePressed() {
        
    }
}

extension MyVehiclesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.vehicles.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleTableViewCell") as! VehicleTableViewCell
        let vehicle = viewModel.vehicles.value![indexPath.row]
        let title = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
        cell.configure(title: title)
        return cell
    }
}
