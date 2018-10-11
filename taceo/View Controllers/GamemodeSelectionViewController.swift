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
        
        classicView.layer.shadowOffset = CGSize(width: 0, height: 5)
        classicView.layer.shadowOpacity = 0.2
        classicView.layer.shadowColor = UIColor.black.cgColor
        classicView.layer.shadowRadius = 5
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
            let destination = segue.destination as? ViewController else { return }
        switch identifier {
        case "classicChosen":
            destination.gamemode = 0
            UserDefaults.standard.set(0, forKey: Constants.UserDefaults.gamemode)
        case "multiplayerChosen":
            destination.gamemode = 1
            UserDefaults.standard.set(1, forKey: Constants.UserDefaults.gamemode)
        default:
            destination.gamemode = nil
        }
    }
    
}
