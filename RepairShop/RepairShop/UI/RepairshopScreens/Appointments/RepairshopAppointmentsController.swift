//
//  RepairshopAppointmentsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import UIKit
import RxSwift

class RepairshopAppointmentsController: BaseController {
    @IBOutlet weak private var tableView: UITableView!
    
    private var viewModel: AppointmentsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = AppointmentsViewModel(userType: .repairShop)
        tableView.delegate = self
        tableView.dataSource = self
        
        bindVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getAppointments(.repairShop)
    }
    
    private func bindVM() {
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.handleError(error: error)
            }).disposed(by: disposeBag)
        
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
        
        viewModel.appointments
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RepairshopAppointmentsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.appointments.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentTableViewCell", for: indexPath) as! AppointmentTableViewCell
        let appointment = viewModel.appointments.value![indexPath.row]
        let vehicleName = String(appointment.vehicle.year) + " " + appointment.vehicle.make + " " + appointment.vehicle.model
        cell.configure(shopName: vehicleName, status: appointment.status)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let appointment = viewModel.appointments.value?[indexPath.row] else { return }
        let vc = instantiateViewController(ofType: RepairshopAppointmentDetailsController.self, inStoryboard: .RepairshopScreens) {
            $0.configure(appointment: appointment)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
