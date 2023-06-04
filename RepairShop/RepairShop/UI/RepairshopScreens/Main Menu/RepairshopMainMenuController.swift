//
//  RepairshopMainMenuController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import UIKit

class RepairshopMainMenuController: BaseController {
    private var viewModel: MainMenuViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainMenuViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setViewControllers([self], animated: false)
    }
    
    @IBAction private func onConversationsPressed() {
        let vc = instantiateViewController(ofType: ConversationsController.self, inStoryboard: .Main)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func onLogOutPressed(_ sender: Any) {
        let vc = instantiateViewController(ofType: LoginController.self, inStoryboard: .Main)
        viewModel.logout()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    @IBAction func onAppointmentsPressed(_ sender: Any) {
        let vc = instantiateViewController(ofType: RepairshopAppointmentsController.self, inStoryboard: .RepairshopScreens)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onProfilePressed(_ sender: Any) {
        // TODO
    }
}
