//
//  MultiplayerGameOverViewController.swift
//  taceo
//
//  Created by Robert May on 1/2/19.
//  Copyright © 2019 Robert May. All rights reserved.
//

import UIKit

class MultiplayerGameOverViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var score: Int?
    var players: [String]?
    var winner: Int?
    var myTurn: Bool?
    var message: String?
    var scoreRead = false
    var setScore = false
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional loading here
        guard let score = score,
            let winner = winner,
            let players = players,
            let myTurn = myTurn
            else { return }
        
        winnerLabel.text = players[winner]
        winnerLabel.textColor = myTurn ? TaceoColors.magenta : TaceoColors.gold
        
        messageLabel.text = message ?? String()
        
        var currentLabel = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            
            // Update score label
            currentLabel += 1
            if currentLabel > score {
                self?.timer?.invalidate()
                self?.scoreRead = true
                self?.setScore = true
            } else {
                self?.scoreLabel.text = String(currentLabel)
                TaceoVibrationControl.heavy.vibrate()
            }
            
        }
        
    }
    
    func trySegue(withIdentifier identifier: String) {
        if scoreRead {
            TaceoVibrationControl.heavy.vibrate()
            performSegue(withIdentifier: identifier, sender: nil)
        } else if !setScore {
            timer?.invalidate()
            guard let score = score else { return }
            setScore = true
            scoreLabel.text = String(score)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
                
                self?.scoreRead = true
                
            })
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        
        trySegue(withIdentifier: "multiplayerGameOverToGameCreation")
        
    }
    
    deinit {
        timer?.invalidate()
    }
    
}

