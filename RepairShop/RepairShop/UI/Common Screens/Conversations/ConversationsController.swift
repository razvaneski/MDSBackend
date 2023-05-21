//
//  ConversationsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import UIKit
import RxSwift

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak private var conversationNameLabel: UILabel!
    @IBOutlet weak private var lastMessageLabel: UILabel!
    
    func configure(receiverName: String, lastMessageDate: Date) {
        self.conversationNameLabel.text = "With: \(receiverName)"
        self.lastMessageLabel.text = "Last message: \(lastMessageDate.formatted())"
    }
}

class ConversationsController: BaseController {
    @IBOutlet weak private var emptyStateLabel: UILabel!
    @IBOutlet weak private var tableView: UITableView!
    
    private var viewModel: ConversationsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.viewModel = ConversationsViewModel()
        
        bindVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getConversations()
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
        
        viewModel.conversations
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] conversations in
                if conversations?.count ?? 0 == 0 {
                    self?.tableView.isHidden = true
                    self?.emptyStateLabel.isHidden = false
                } else {
                    self?.tableView.isHidden = false
                    self?.emptyStateLabel.isHidden = true
                }
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ConversationsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversations.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationTableViewCell", for: indexPath) as! ConversationTableViewCell
        
        let conversation = viewModel.conversations.value![indexPath.row]
        let receiverName = viewModel.isCurrentUserRepairshop ? conversation.userName : conversation.repairshopName
        let lastMessageDate = conversation.messages.last!.date
        
        cell.configure(receiverName: receiverName, lastMessageDate: lastMessageDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = viewModel.conversations.value![indexPath.row]
        let vc = instantiateViewController(ofType: ConversationMessagesController.self, inStoryboard: .Main) {
            $0.configure(viewModel: .init(initialConversation: conversation))
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
