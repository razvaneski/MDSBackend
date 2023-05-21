//
//  ConversationMessagesController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import UIKit
import RxSwift

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak private var receivedMessageLabel: UILabel!
    @IBOutlet weak private var receivedDateLabel: UILabel!
    @IBOutlet weak private var sentMessageLabel: UILabel!
    @IBOutlet weak private var sentDateLabel: UILabel!
    
    func configure(received: Bool, message: String, date: Date) {
        if received {
            receivedMessageLabel.superview?.isHidden = false
            sentMessageLabel.superview?.isHidden = true
            
            receivedMessageLabel.text = message
            receivedDateLabel.text = date.formatted()
        } else {
            receivedMessageLabel.superview?.isHidden = true
            sentMessageLabel.superview?.isHidden = false
            
            sentMessageLabel.text = message
            sentDateLabel.text = date.formatted()
        }
    }
}

class ConversationMessagesController: BaseController {
    @IBOutlet weak private var messageTextField: UITextField!
    @IBOutlet weak private var tableView: UITableView!
    
    private var viewModel: ConversationMessagesViewModel!
    
    func configure(viewModel: ConversationMessagesViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        viewModel.errorSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] error in
                self?.handleError(error: error)
            }.disposed(by: disposeBag)
        
        viewModel.conversation
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onSendPressed() {
        guard let message = messageTextField.text, !message.isEmpty else {
            showErrorMessage("Message cannot be empty.")
            return
        }
        viewModel.sendMessage(message)
        messageTextField.text = ""
    }
}

extension ConversationMessagesController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversation.value.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
        
        let message = viewModel.conversation.value.messages[indexPath.row]
        
        cell.configure(
            received: viewModel.currentUserId != message.userId,
            message: message.message,
            date: message.date
        )
        return cell
    }
    
    
}
