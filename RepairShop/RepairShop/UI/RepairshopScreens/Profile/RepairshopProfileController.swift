//
//  RepairshopProfileController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 05.06.2023.
//

import UIKit
import RxSwift

class RepairshopProfileTableCell: UITableViewCell {
    @IBOutlet weak private var openingHoursLabel: UILabel!
    @IBOutlet weak private var phoneLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var addressLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    
    func configure(repairshop: Repairshop) {
        self.openingHoursLabel.text = "Opening Hours: \(repairshop.startTime)-\(repairshop.endTime)"
        self.phoneLabel.text = repairshop.phone
        self.emailLabel.text = repairshop.email
        self.addressLabel.text = repairshop.address
        self.nameLabel.text = repairshop.name
    }
}

protocol LockedIntervalTableCellDelegate: AnyObject {
    func didRemoveInterval(_ interval: LockedInterval)
}

class LockedIntervalTableCell: UITableViewCell {
    @IBOutlet weak private var fromDateLabel: UILabel!
    @IBOutlet weak private var toDateLabel: UILabel!
    
    private var lockedInterval: LockedInterval!
    weak var delegate: LockedIntervalTableCellDelegate?
    
    func configure(lockedInterval: LockedInterval) {
        self.lockedInterval = lockedInterval
        self.fromDateLabel.text = "From: \(lockedInterval.startDate.formatted())"
        self.toDateLabel.text = "To: \(lockedInterval.endDate.formatted())"
    }
    
    @IBAction private func onDeletePressed(_ sender: Any) {
        delegate?.didRemoveInterval(self.lockedInterval)
    }
}

enum RepairshopProfileViewModelEvent {
    case removeIntervalSuccess
    case addIntervalSuccess
}

class RepairshopProfileViewModel: BaseViewModel<RepairshopProfileViewModelEvent> {
    let repairshop = Variable<Repairshop?>(nil)
    let lockedIntervals = Variable<[LockedInterval]?>(nil)
    
    override init() {
        super.init()
        self.fetchData()
    }
    
    func fetchData() {
        getRepairshop()
        getLockedIntervals()
    }
    
    private func getRepairshop() {
        let repairshopId = UserService.shared.currentUserInfo.id
        RepairshopsService.shared.getRepairshop(repairshopId: repairshopId)
            .asObservable()
            .subscribe { [weak self] repairshop in
                self?.repairshop.value = repairshop
            } onError: { [weak self] error in
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    private func getLockedIntervals() {
        let repairshopId = UserService.shared.currentUserInfo.id
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.getLockedIntervals(repairshopId: repairshopId)
            .asObservable()
            .subscribe { [weak self] intervals in
                self?.stateSubject.onNext(.idle)
                self?.lockedIntervals.value = intervals
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    func removeLockedInterval(_ lockedInterval: LockedInterval) {
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.removeLockedInterval(lockedIntervalId: lockedInterval.id)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.removeIntervalSuccess)
                self?.getLockedIntervals()
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    func addLockedInterval(startDate: Date, endDate: Date) {
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.addLockedInterval(startDate: startDate, endDate: endDate)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.addIntervalSuccess)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
}

class RepairshopProfileController: BaseController {
    @IBOutlet weak private var tableView: UITableView!
    
    private var viewModel: RepairshopProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.viewModel = RepairshopProfileViewModel()
        
        bindVM()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetchData()
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
                case .removeIntervalSuccess:
                    self?.showSuccessMessage("Interval removed successfully.")
                case .addIntervalSuccess:
                    break
                }
            }.disposed(by: disposeBag)
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
        
        viewModel.lockedIntervals
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
        
        viewModel.repairshop
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddLockedIntervalPressed(_ sender: Any) {
        let vc = instantiateViewController(ofType: AddLockedIntervalController.self, inStoryboard: .RepairshopScreens)
        vc.viewModel = self.viewModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RepairshopProfileController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if viewModel.repairshop.value != nil {
                return 1
            }
            return 0
        }
        return viewModel.lockedIntervals.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepairshopProfileTableCell", for: indexPath) as! RepairshopProfileTableCell
            cell.configure(repairshop: viewModel.repairshop.value!)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LockedIntervalTableCell", for: indexPath) as! LockedIntervalTableCell
        cell.delegate = self
        cell.configure(lockedInterval: viewModel.lockedIntervals.value![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Details"
        }
        return "Locked Intervals"
    }
}

extension RepairshopProfileController: LockedIntervalTableCellDelegate {
    func didRemoveInterval(_ interval: LockedInterval) {
        viewModel.removeLockedInterval(interval)
    }
}
