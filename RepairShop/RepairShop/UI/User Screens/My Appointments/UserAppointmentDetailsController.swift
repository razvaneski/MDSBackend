//
//  UserAppointmentDetailsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 20.05.2023.
//

import UIKit
import RxSwift

enum AppointmentDetailsViewModelEvent {
    case statusChanged(newStatus: Appointment.Status)
    case goToConversation(conversation: Conversation)
    case addReviewSuccess
}

class AppointmentDetailsViewModel: BaseViewModel<AppointmentDetailsViewModelEvent> {
    let userInfo = UserService.shared.currentUserInfo
    var appointment: Appointment!
    
    init(appointment: Appointment!) {
        self.appointment = appointment
    }
    
    func changeAppointmentStatus(id: String, status: Appointment.Status) {
        self.stateSubject.onNext(.loading)
        AppointmentsService.shared.changeAppointmentStatus(id: id, newStatus: status)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
                self?.eventSubject.onNext(.statusChanged(newStatus: status))
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)

    }
    
    func getConversation(receiverId: String) {
        self.stateSubject.onNext(.loading)
        ConversationsService.shared.getConversation(receiverId: receiverId)
            .asObservable()
            .subscribe { [weak self] conversation in
                self?.eventSubject.onNext(.goToConversation(conversation: conversation))
                self?.stateSubject.onNext(.idle)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
    
    func sendReview(rating: Int, message: String) {
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.addReview(repairshopId: appointment.repairshop.id, rating: rating, message: message)
            .subscribe { [weak self] in
                self?.stateSubject.onNext(.idle)
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
}

class UserAppointmentDetailsController: BaseController {
    @IBOutlet weak private var shopNameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var vehicleLabel: UILabel!
    @IBOutlet weak private var addReviewButton: UIButton!
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var cancelButton: UIButton!

    private var viewModel: AppointmentDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
        configureUI()
    }
    
    func configure(appointment: Appointment) {
        self.viewModel = AppointmentDetailsViewModel(appointment: appointment)
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
    
    private func configureUI() {
        let appointment = viewModel.appointment!
        
        self.shopNameLabel.text = "Shop name: \(appointment.repairshop.name)"
        self.dateLabel.text = "Date: \(appointment.date.formatted())"
        self.vehicleLabel.text = "Vehicle: \(appointment.vehicle.year) \(appointment.vehicle.make) \(appointment.vehicle.model)"
        self.statusLabel.text = "Status: \(appointment.status.rawValue)"
        
        self.addReviewButton.isHidden = true
        switch appointment.status {
        case .pending:
            statusLabel.textColor = .systemOrange
        case .completed:
            statusLabel.textColor = .systemPurple
            self.addReviewButton.isHidden = false
            cancelButton.isHidden = true
        case .confirmed:
            statusLabel.textColor = .systemGreen
        case .declined, .cancelled:
            statusLabel.textColor = .systemRed
            cancelButton.isHidden = true
        }
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onCancelAppointmentPressed() {
        self.viewModel.changeAppointmentStatus(id: viewModel.appointment.id, status: .cancelled)
    }
    
    @IBAction func onSendMessagePressed(_ sender: Any) {
        self.viewModel.getConversation(receiverId: viewModel.appointment.repairshop.id)
    }
    
    @IBAction func onAddReviewPressed(_ sender: Any) {
        let vc = instantiateViewController(ofType: AddRatingController.self, inStoryboard: .UserScreens) {
            $0.delegate = self
        }
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}

extension UserAppointmentDetailsController: AddRatingControllerDelegate {
    func didSendReview(rating: Int, message: String) {
        viewModel.sendReview(rating: rating, message: message)
    }
}
