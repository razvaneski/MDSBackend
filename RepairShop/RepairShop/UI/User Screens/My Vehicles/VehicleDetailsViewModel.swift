//
//  VehicleDetailsViewModel.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import UIKit
import RxSwift

enum VehicleDetailsViewModelEvent {
    case updateSuccess
}

class VehicleDetailsViewModel: BaseViewModel<VehicleDetailsViewModelEvent> {
    let vehicle = Variable<Vehicle?>(nil)
    
    init(id: String) {
        super.init()
        getVehicle(id: id)
    }
    
    private func getVehicle(id: String) {
        self.stateSubject.onNext(.loading)
        VehiclesService.shared.getVehicle(id: id)
            .asObservable()
            .subscribe { [weak self] vehicle in
                self?.stateSubject.onNext(.idle)
                self?.vehicle.value = vehicle
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    func updateVehicle(make: String, model: String, year: Int, vin: String, licensePlate: String) {
        guard let id = vehicle.value?.id else { return }
        self.stateSubject.onNext(.loading)
        VehiclesService.shared.updateVehicle(id: id, make: make, model: model, year: year, vin: vin, licensePlate: licensePlate)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.updateSuccess)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)

    }
}
