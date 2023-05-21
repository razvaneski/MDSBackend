//
//  UIView+Utils.swift
//  RepairShop
//
//  Created by Razvan Dumitriu on 21.05.2023.
//

import UIKit

extension UIView {
    @IBInspectable
    var radius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
