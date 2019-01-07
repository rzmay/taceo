//
//  UIViewController+hideKeyboard.swift
//  Vialert
//
//  Created by Robert May on 7/25/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupKeyboard() {
        self.hideKeyboardWhenTappedAround()
    }
}

