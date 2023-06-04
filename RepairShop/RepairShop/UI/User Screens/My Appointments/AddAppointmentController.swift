//
//  AddAppointmentController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 02.06.2023.
//

import UIKit
import RxSwift

class SelectableTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(name: String) {
        self.nameLabel.text = name
    }
}

enum AddAppointmentViewModelEvent {
    case addSuccess
}

class AddAppointmentViewModel: BaseViewModel<AddAppointmentViewModelEvent> {
    let vehicles = Variable<[Vehicle]>([])
    let repairShops = Variable<[Repairshop]>([])
    
    var selectedVehicle: Vehicle? = nil
    var selectedRepairShop: Repairshop? = nil
    
    override init() {
        super.init()
        getVehicles()
        getRepairShops()
    }
    
    private func getVehicles() {
        self.stateSubject.onNext(.loading)
        VehiclesService.shared.getVehicles()
            .asObservable()
            .subscribe { [weak self] vehicles in
                self?.stateSubject.onNext(.idle)
                self?.vehicles.value = vehicles
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    private func getRepairShops() {
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.getRepairshops()
            .asObservable()
            .subscribe { [weak self] repairshops in
                self?.repairShops.value = repairshops
                self?.stateSubject.onNext(.idle)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    func addAppointment(date: Date) {
        guard let selectedVehicle, let selectedRepairShop else { return }
        self.stateSubject.onNext(.loading)
        AppointmentsService.shared.addAppointment(vehicleId: selectedVehicle.id, repairshopId: selectedRepairShop.id, date: date)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.addSuccess)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)

    }
}

class AddAppointmentController: BaseController {
    @IBOutlet weak private var repairshopTableView: UITableView!
    @IBOutlet weak private var vehicleTableView: UITableView!
    @IBOutlet weak private var datePicker: UIDatePicker!
    
    private var viewModel: AddAppointmentViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddAppointmentViewModel()
        
        vehicleTableView.dataSource = self
        vehicleTableView.delegate = self
        
        repairshopTableView.delegate = self
        repairshopTableView.dataSource = self
        
        bindVM()
    }
    
    private func bindVM() {
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
        
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .addSuccess:
                    self?.showSuccessMessage("Appointment added successfully.")
                    self?.navigationController?.popViewController(animated: true)
                    break
                }
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(
            viewModel.vehicles.asObservable(),
            viewModel.repairShops.asObservable()
        ).subscribe { [weak self] _ in
            self?.repairshopTableView.reloadData()
            self?.vehicleTableView.reloadData()
            self?.viewModel.selectedVehicle = nil
            self?.viewModel.selectedRepairShop = nil
        }.disposed(by: disposeBag)
    }
    
    @IBAction private func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddAppointmentPressed(_ sender: Any) {
        guard let _ = viewModel.selectedVehicle else {
            showErrorMessage("Please select a vehicle.")
            return
        }
        guard let _ = viewModel.selectedRepairShop else {
            showErrorMessage("Please select a repairshop.")
            return
        }
        guard datePicker.date > Date.now else {
            showErrorMessage("Invalid date")
            return
        }
        viewModel.addAppointment(date: datePicker.date)
    }
}

extension AddAppointmentController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == repairshopTableView {
            return viewModel.repairShops.value.count
        }
        return viewModel.vehicles.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == repairshopTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableTableViewCell", for: indexPath) as! SelectableTableViewCell
            let repairshop = viewModel.repairShops.value[indexPath.row]
            cell.configure(name: repairshop.name)
            if repairshop.id == viewModel.selectedRepairShop?.id {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableTableViewCell", for: indexPath) as! SelectableTableViewCell
        let vehicle = viewModel.vehicles.value[indexPath.row]
        cell.configure(name:
                        String(vehicle.year) + " " +
                       vehicle.make + " " +
                       vehicle.model
        )
        if vehicle.id == viewModel.selectedVehicle?.id {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        if tableView == repairshopTableView {
            let selectedRepairshop = viewModel.repairShops.value[indexPath.row]
            viewModel.selectedRepairShop = selectedRepairshop
        } else {
            let selectedVehicle = viewModel.vehicles.value[indexPath.row]
            viewModel.selectedVehicle = selectedVehicle
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        
        if tableView == repairshopTableView {
            viewModel.selectedRepairShop = nil
        } else {
            viewModel.selectedVehicle = nil
        }
    }
}
