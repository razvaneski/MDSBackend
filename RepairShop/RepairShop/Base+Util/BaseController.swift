//
//  BaseController.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 06.05.2023.
//

import UIKit
import RxSwift
import SwiftMessages

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)

    override func loadView() {
        view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.16)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

class BaseController: UIViewController {
    let disposeBag = DisposeBag()
    
    private var loaderController: SpinnerViewController?
    
    func showLoader() {
        loaderController = SpinnerViewController()
        
        addChild(loaderController!)
        loaderController!.view.frame = view.frame
        view.addSubview(loaderController!.view)
        loaderController!.didMove(toParent: self)
    }
    
    func hideLoader() {
        guard let loaderController else { return }
        loaderController.willMove(toParent: nil)
        loaderController.view.removeFromSuperview()
        loaderController.removeFromParent()
    }
    
    func handleError(error: Error) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        
        if let appError = error as? ApplicationError {
            switch appError {
            case .invalidToken:
                view.configureContent(title: "Error!", body: "Invalid token")
            case .message(str: let message):
                view.configureContent(title: "Error!", body: message)
            case .warning(message: let message):
                view.configureContent(title: "Warning!", body: message)
                view.configureTheme(.warning)
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
    
    func showErrorMessage(_ string: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        
        view.configureContent(title: "Error!", body: string)
        view.button?.isHidden = true
        
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(view: view)
    }
    
    func showSuccessMessage(_ string: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.configureDropShadow()
        
        view.configureContent(title: "Success!", body: string)
        view.button?.isHidden = true
        
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(view: view)
    }
}
