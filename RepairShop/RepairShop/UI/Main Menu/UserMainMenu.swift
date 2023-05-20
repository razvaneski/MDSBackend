//
//  UserMainMenu.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import UIKit
import RxSwift

class UserMainMenu: BaseController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setViewControllers([self], animated: false)
    }
    
    @IBAction private func onMyVehiclesPressed() {
        let vc = instantiateViewController(ofType: MyVehiclesController.self, inStoryboard: .UserScreens)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func onMyAppointmentsPressed() {
        let vc = instantiateViewController(ofType: MyAppointmentsController.self, inStoryboard: .UserScreens)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
