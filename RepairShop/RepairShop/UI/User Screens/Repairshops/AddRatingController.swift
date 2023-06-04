//
//  AddRatingController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 04.06.2023.
//

import UIKit
import RxSwift

protocol AddRatingControllerDelegate: AnyObject {
    func didSendReview(rating: Int, message: String)
}

class AddRatingController: BaseController {
    @IBOutlet weak private var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet weak private var messageTextField: UITextField!
    
    weak var delegate: AddRatingControllerDelegate?
    
    @IBAction private func onCancelPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func onSendPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.didSendReview(rating: self.ratingSegmentedControl.selectedSegmentIndex + 1, message: self.messageTextField.text ?? "")
        }
    }
}
