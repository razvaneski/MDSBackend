//
//  UserMainMenu.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 07.05.2023.
//

import UIKit
import RxSwift

enum MainMenuViewModelEvent {}

class MainMenuViewModel: BaseViewModel<MainMenuViewModelEvent> {
    func logout() {
        UserService.shared.logout()
    }
}

class UserMainMenu: BaseController {
    private var viewModel: MainMenuViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainMenuViewModel()
    }
    
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
    
    @IBAction private func onLogOutPressed(_ sender: Any) {
        let vc = instantiateViewController(ofType: LoginController.self, inStoryboard: .Main)
        viewModel.logout()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    
    @IBAction private func onMessagesPressed(_ sender: Any) {
        let vc = instantiateViewController(ofType: ConversationsController.self, inStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
