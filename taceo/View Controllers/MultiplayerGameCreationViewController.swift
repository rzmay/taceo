//
//  MultiplayerGameCreationViewController.swift
//  taceo
//
//  Created by Robert May on 10/22/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

class MultiplayerGameCreationViewController: UIViewController {
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var gamePasswordTextField: UITextField!
    
    @IBOutlet weak var swipeRightLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    var nicknameIsSet: Bool = false
    var passwordIsSet: Bool = false
    var nickname: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setShadow()
        mainView.layer.shadowOpacity = 0.2
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowRadius = 5
        
        let nickname = UserDefaults.standard.string(forKey: Constants.UserDefaults.nickname)
        
        if let nickname = nickname {
            nicknameTextField.text = nickname
        }
        
        nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(_:)), for: .editingChanged)
        gamePasswordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange(_:)), for: .editingChanged)
        
        nicknameTextFieldDidChange(nicknameTextField)
        passwordTextFieldDidChange(gamePasswordTextField)
        
    }
    
    func setShadow() {
        if UIDevice.current.orientation.isLandscape {
            mainView.layer.shadowOffset = CGSize(width: 5, height: 0)
        } else {
            mainView.layer.shadowOffset = CGSize(width: 0, height: 5)
        }
    }
    
    @objc func nicknameTextFieldDidChange(_ textField: UITextField) {
        
        guard let text = textField.text else { return }
        UserDefaults.standard.set(text, forKey: Constants.UserDefaults.nickname)
        if checkNotEmpty(for: text) {
            swipeRightLabel.isHidden = false
            nicknameIsSet = true
            nickname = text
        } else {
            swipeRightLabel.isHidden = true
            nicknameIsSet = false
        }
        
    }
    
    @objc func passwordTextFieldDidChange(_ textField: UITextField) {
        
        guard let text = textField.text else { return }
        if checkNotEmpty(for: text) {
            privacyLabel.isHidden = false
            passwordIsSet = true
            password = text
        } else {
            privacyLabel.isHidden = true
            passwordIsSet = false
        }
        
    }
    
    @IBAction func handleSwipeLeft(_ sender: UISwipeGestureRecognizer) {
        if nicknameIsSet {
            performSegue(withIdentifier: "toMultiplayerGame", sender: nil)
        }
    }
    
    @IBAction func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "cancelGameCreation", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "toMultiplayerGame":
            guard let destination = segue.destination as? MultiplayerGameViewController else { return }
            destination.privacyStatus = (priv: passwordIsSet, pass: password)
            destination.nickname = nickname
        default:
            break
        }
        
    }
    
    
    func checkNotEmpty(for string: String) -> Bool {
        let numSpaces = string.components(separatedBy:" ").count - 1

        if numSpaces == string.count {
            return false
        } else {
            return true
        }
    }
    
}
