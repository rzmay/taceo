//
//  GamemodeSelectionViewController.swift
//  taceo
//
//  Created by Robert May on 10/10/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

class GamemodeSelectionViewController: UIViewController {
    
    @IBOutlet weak var classicView: UIView!
    @IBOutlet weak var multiplayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setShadow()
        classicView.layer.shadowOpacity = 0.2
        classicView.layer.shadowColor = UIColor.black.cgColor
        classicView.layer.shadowRadius = 5
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "classicChosen":
            
            UserDefaults.standard.set(0, forKey: Constants.UserDefaults.gamemode)
        case "multiplayerChosen":
            UserDefaults.standard.set(1, forKey: Constants.UserDefaults.gamemode)
        default:
            assertionFailure("Unexpected segue: \(identifier)")
        }
    }
    
    func setShadow() {
        if UIDevice.current.orientation.isLandscape {
            classicView.layer.shadowOffset = CGSize(width: 5, height: 0)
        } else {
            print("Portrait")
            classicView.layer.shadowOffset = CGSize(width: 0, height: 5)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setShadow()
    }
    
}
