//
//  RepairshopAppointmentDetailsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 02.06.2023.
//

import UIKit
import RxSwift

class RepairshopAppointmentDetailsController: BaseController {
    @IBOutlet weak private var sendMessageButton: UIButton!
    @IBOutlet weak private var confirmAppointmentButton: UIButton!
    @IBOutlet weak private var declineAppointmentButton: UIButton!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var vehicleLabel: UILabel!
    @IBOutlet weak private var statusLabel: UILabel!
    
    private var viewModel: AppointmentDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
        configureUI()
    }
    
    func configure(appointment: Appointment) {
        self.viewModel = AppointmentDetailsViewModel(appointment: appointment)
    }
    
    private func configureUI() {
        let appointment = viewModel.appointment!
        
        self.dateLabel.text = "Date: \(appointment.date.formatted())"
        self.vehicleLabel.text = "Vehicle: \(appointment.vehicle.year) \(appointment.vehicle.make) \(appointment.vehicle.model)"
        self.statusLabel.text = "Status: \(appointment.status.rawValue)"
        
        switch appointment.status {
        case .pending:
            statusLabel.textColor = .systemOrange
            confirmAppointmentButton.isHidden = false
            declineAppointmentButton.isHidden = false
        case .completed:
            statusLabel.textColor = .systemPurple
            confirmAppointmentButton.isHidden = true
            declineAppointmentButton.isHidden = true
        case .confirmed:
            statusLabel.textColor = .systemGreen
            confirmAppointmentButton.isHidden = true
            declineAppointmentButton.isHidden = false
        case .declined, .cancelled:
            statusLabel.textColor = .systemRed
            confirmAppointmentButton.isHidden = true
            declineAppointmentButton.isHidden = true
        }
    }
    
    private func bindVM() {
        viewModel.eventSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
                case .statusChanged(let newStatus):
                    switch newStatus {
                    case .cancelled:
                        self?.showSuccessMessage("Appointment cancelled successfully.")
                        self?.navigationController?.popViewController(animated: true)
                    case .confirmed:
                        self?.showSuccessMessage("Appointment confirmed successfully.")
                        self?.navigationController?.popViewController(animated: true)
                    case .declined:
                        self?.showSuccessMessage("Appointment declined successfully.")
                        self?.navigationController?.popViewController(animated: true)
                    default:
                        break
                    }
                    
                case .goToConversation(conversation: let conversation):
                    let vc = instantiateViewController(ofType: ConversationMessagesController.self, inStoryboard: .Main) {
                        let viewModel = ConversationMessagesViewModel(initialConversation: conversation)
                        $0.configure(viewModel: viewModel)
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                case .addReviewSuccess:
                    self?.showSuccessMessage("Review added successfully.")
                }
            }.disposed(by: disposeBag)
        
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

    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onConfirmAppointmentPressed() {
        viewModel.changeAppointmentStatus(id: viewModel.appointment.id, status: .confirmed)
    }
    
    @IBAction private func onDeclineAppointmentPressed() {
        viewModel.changeAppointmentStatus(id: viewModel.appointment.id, status: .declined)
    }
    
    @IBAction private func onSendMessagePressed() {
        viewModel.getConversation(receiverId: viewModel.appointment.vehicle.userId)
    }
}
