//
//  RepairshopDetailsController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 04.06.2023.
//

import UIKit
import RxSwift

enum RepairshopDetailsViewModelEvent {}

class RepairshopDetailsViewModel: BaseViewModel<RepairshopDetailsViewModelEvent> {
    var repairshop: Repairshop!
    let reviews = Variable<[Review]?>(nil)
    
    init(repairshop: Repairshop) {
        super.init()
        self.repairshop = repairshop
        getReviews()
    }
    
    private func getReviews() {
        self.stateSubject.onNext(.loading)
        RepairshopsService.shared.getReviews(repairshopId: repairshop.id)
            .asObservable()
            .subscribe { [weak self] reviews in
                self?.stateSubject.onNext(.idle)
                self?.reviews.value = reviews
            } onError: { [weak self] error in
                self?.stateSubject.onNext(.idle)
                self?.errorSubject.onNext(error)
            }.disposed(by: disposeBag)
    }
}

class RepairshopDetailsTableCell: UITableViewCell {
    @IBOutlet weak private var phoneLabel: UILabel!
    @IBOutlet weak private var emailLabel: UILabel!
    @IBOutlet weak private var addressLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var ratingLabel: UILabel!
    
    func configure(repairshop: Repairshop, reviews: [Review]?) {
        self.phoneLabel.text = repairshop.phone
        self.emailLabel.text = repairshop.email
        self.addressLabel.text = repairshop.address
        self.nameLabel.text = repairshop.name
        
        if let reviews, reviews.count > 0 {
            self.ratingLabel.isHidden = false
            let meanRating: Double = Double(reviews.map({$0.rating}).reduce(0, +) / reviews.count)
            self.ratingLabel.text = "Rating: \(meanRating)/5"
        } else {
            self.ratingLabel.isHidden = true
        }
        
        self.layoutIfNeeded()
    }
}

class RepairshopReviewTableCell: UITableViewCell {
    @IBOutlet weak private var ratingLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    
    func configure(review: Review) {
        self.ratingLabel.text = "Rating: \(review.rating)/5"
        self.messageLabel.text = review.message
    }
}

class RepairshopDetailsController: BaseController {
    @IBOutlet weak private var tableView: UITableView!
    
    private var viewModel: RepairshopDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        bindVM()
    }
    
    func configure(repairshop: Repairshop) {
        self.viewModel = RepairshopDetailsViewModel(repairshop: repairshop)
    }
    
    private func bindVM() {
        viewModel.stateSubject
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                switch event {
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
        
        viewModel.reviews
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    @IBAction private func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RepairshopDetailsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return viewModel.reviews.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepairshopDetailsTableCell", for: indexPath) as! RepairshopDetailsTableCell
            cell.configure(repairshop: viewModel.repairshop, reviews: viewModel.reviews.value)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepairshopReviewTableCell", for: indexPath) as! RepairshopReviewTableCell
        cell.configure(review: viewModel.reviews.value![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Details"
        }
        return "Reviews"
    }
}
