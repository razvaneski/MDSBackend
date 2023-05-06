//
//  BaseController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import UIKit
import RxSwift
import SwiftMessages

class BaseController: UIViewController {
    let disposeBag = DisposeBag()
    
    func showLoader() {
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoader() {
        if let vc = self.presentedViewController, vc is UIAlertController {
            self.dismiss(animated: true)
        }
    }
    
    func handleError(error: Error) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        
        if let appError = error as? ApplicationError {
            switch appError {
            case .invalidToken:
                view.configureContent(title: "Error!", body: "Invalid token")
            }
        } else if let networkError = error as? NetworkError {
            switch networkError {
            case .httpErrorCode(code: let code):
                view.configureContent(title: "Error!", body: "Network error (code: \(code))")
            }
        } else {
            view.configureContent(title: "Error!", body: "An unexpected error occured, please try again")
        }
        view.button?.isHidden = true
        
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(view: view)
    }
}
