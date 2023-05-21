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
    @IBOutlet weak private var emptyStateLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private let viewModel = MyVehiclesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getVehicles()
    }
    
    private func bindVM() {
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .deleteSuccess:
                    self?.showSuccessMessage("Deleted successfully")
                    self?.viewModel.getVehicles()
                }
            }).disposed(by: disposeBag)
        
        viewModel.vehicles
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] vehicles in
                if vehicles?.count ?? 0 == 0 {
                    self?.tableView.isHidden = true
                    self?.emptyStateLabel.isHidden = false
                } else {
                    self?.tableView.isHidden = false
                    self?.emptyStateLabel.isHidden = true
                }
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
        let vc = instantiateViewController(ofType: AddVehicleController.self, inStoryboard: .UserScreens)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vehicleId = viewModel.vehicles.value![indexPath.row].id
        let vc = instantiateViewController(ofType: VehicleDetailsController.self, inStoryboard: .UserScreens) {
            $0.configure(vehicleId: vehicleId)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
