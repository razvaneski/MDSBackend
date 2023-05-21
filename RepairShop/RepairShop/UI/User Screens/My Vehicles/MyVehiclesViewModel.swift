//
//  MyVehiclesViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import Foundation
import RxSwift

enum MyVehiclesViewModelEvent {
    case deleteSuccess
}

class MyVehiclesViewModel: BaseViewModel<MyVehiclesViewModelEvent> {
    let vehicles = Variable<[Vehicle]?>(nil)
    
    override init() {
        super.init()
        getVehicles()
    }
    
    func getVehicles() {
        stateSubject.onNext(.loading)
        VehiclesService.shared.getVehicles()
            .asObservable()
            .subscribe(onNext: { [weak self] vehicles in
                self?.stateSubject.onNext(.idle)
                self?.vehicles.value = vehicles
            }, onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }).disposed(by: disposeBag)
    }
    
    func deleteVehicle(id: String) {
        stateSubject.onNext(.loading)
        VehiclesService.shared.deleteVehicle(id: id)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.deleteSuccess)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.deleteSuccess)
            }.disposed(by: disposeBag)

    }
}
