//
//  RepairshopsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 04.06.2023.
//

import UIKit
import RxSwift

enum RepairshopsViewModelEvent {}

class RepairshopsViewModel: BaseViewModel<RepairshopsViewModelEvent> {
    let repairshops = Variable<[Repairshop]?>(nil)
    
    override init() {
        super.init()
        getRepairshops()
    }
    
    private func getRepairshops() {
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.getRepairshops()
            .asObservable()
            .subscribe { [weak self] repairshops in
                self?.stateSubject.onNext(.idle)
                self?.repairshops.value = repairshops
            } onError: { [weak self] error in
                self?.errorSubject.onNext(error)
                self?.stateSubject.onNext(.idle)
            }.disposed(by: disposeBag)
    }
}

class RepairshopTableViewCell: UITableViewCell {
    @IBOutlet weak private var shopName: UILabel!
    
    func configure(shopName: String) {
        self.shopName.text = shopName
    }
}

class RepairshopsController: BaseController {
    @IBOutlet weak private var tableView: UITableView!
    
    
    private var viewModel: RepairshopsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.viewModel = RepairshopsViewModel()
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

        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
        
        viewModel.repairshops
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RepairshopsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repairshops.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepairshopTableViewCell", for: indexPath) as! RepairshopTableViewCell
        let shop = viewModel.repairshops.value![indexPath.row]
        cell.configure(shopName: shop.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = instantiateViewController(ofType: RepairshopDetailsController.self, inStoryboard: .UserScreens) {
            let repairshop = viewModel.repairshops.value![indexPath.row]
            $0.configure(repairshop: repairshop)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
