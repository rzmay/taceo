//
//  ViewController.swift
//  taceo
//
//  Created by Robert May on 10/5/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var gamemodeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var gamemode: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if gamemode == nil {
            gamemode = UserDefaults.standard.integer(forKey: Constants.UserDefaults.gamemode)
        }
        
        guard let gamemode = gamemode else { return }
        
        switch gamemode {
        case 0:
            gamemodeLabel.text = "classic"
            gamemodeLabel.textColor = TaceoColors.magenta

        case 1:
            gamemodeLabel.text = "multiplayer"
            gamemodeLabel.textColor = TaceoColors.gold
            
        default:
            gamemodeLabel.text = "UNKNOWN GAMEMODE"
            assertionFailure("unknown gamemode")
        }
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        switch gamemode {
        case 0:
            performSegue(withIdentifier: "segueToClassic", sender: nil)
        case 1:
            performSegue(withIdentifier: "segueToMultiplayer", sender: nil)
        default:
            print("Unexpected gamemode: \(String(describing: gamemode))")
        }
    }
    
}

