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
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var gamemode: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        super.viewWillAppear(animated)
        
        gamemode = UserDefaults.standard.integer(forKey: Constants.UserDefaults.gamemode)

        guard let gm = gamemode else { return }
        print("gamemode: \(gm)")
        
        switch gm {
        case 0:
            gamemodeLabel.text = "classic"
            gamemodeLabel.textColor = TaceoColors.magenta
            
            highScoreLabel.textColor = TaceoColors.magenta
            
            let highScore = Int( CoreDataHelper.retrieveHighScore()?.score ?? 0 )
            highScoreLabel.text = String(highScore)

        case 1:
            gamemodeLabel.text = "multiplayer"
            gamemodeLabel.textColor = TaceoColors.gold
            
            highScoreLabel.textColor = TaceoColors.gold
            
            highScoreLabel.text = "None"
            
        default:
            gamemodeLabel.text = "UNKNOWN GAMEMODE"
            // Use classic
            UserDefaults.standard.set(0, forKey: Constants.UserDefaults.gamemode)
            gamemodeLabel.text = "classic"
            gamemode = 0
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleDownSwipe))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    @objc func handleDownSwipe() {
        // Nonexistent
        // performSegue(withIdentifier: "toTutorial", sender: nil)
    }
    
    @IBAction func unwindToTitle(_ segue: UIStoryboardSegue) {
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

