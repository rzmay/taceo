//
//  MultiplayerGameViewController.swift
//  taceo
//
//  Created by Robert May on 10/12/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

class MultiplayerGameViewController: UIViewController {
    @IBOutlet weak var tapIndicationLabel: UILabel!
    
    var recognizeLong = true
    var privacyStatus: (priv: Bool, pass: String)?
    var nickname: String?
    var gameId: String?
    var tapManager: TaceoSequenceManager.Multiplayer?
    var message: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tapManager = TaceoSequenceManager.Multiplayer(
            client: nickname ?? "guest",
            privacy: privacyStatus ?? (priv: false, pass: "none")
        ) { [weak self] tap in
            switch tap {
            case .short:
                self?.tapIndicationLabel.text = "tap"
            case .long:
                self?.tapIndicationLabel.text = "long press"
            case .swipe:
                self?.tapIndicationLabel.text = "swipe"
            }
        }
        tapManager?.viewController = self
    }
    
    func changeColor(to turn: Int) {
        tapIndicationLabel.textColor =  [TaceoColors.gold, TaceoColors.magenta][turn]
    }
    
    func returnToCreation() {
        performSegue(withIdentifier: "multiplayerToCreation", sender: nil)
    }
    
    func handleSwipe() {
        print("swipe")
        tapManager?.input(tap: .swipe)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        recognizeLong = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        recognizeLong = true
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        print("tap")
        tapManager?.input(tap: .short)
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if recognizeLong {
            print("long press")
            tapManager?.input(tap: .long)
            recognizeLong = false
        }
    }
    
    @IBAction func handleRightSwipe(_ sender: UISwipeGestureRecognizer) {
        handleSwipe()
    }
    
    @IBAction func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        handleSwipe()
    }
    
    @IBAction func handleUpSwipe(_ sender: UISwipeGestureRecognizer) {
        handleSwipe()
    }
    
    @IBAction func handleDownSwipe(_ sender: UISwipeGestureRecognizer) {
        handleSwipe()
    }
    
    func endGame(message m: String) {
        message = m
        performSegue(withIdentifier: "multiplayerToGameOver", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        if identifier == "multiplayerToCreation" {
            guard let destination = segue.destination as? MultiplayerGameCreationViewController else {return}
            destination.errorMessage = tapManager?.joinError ?? ""
        } else if identifier == "multiplayerToGameOver" {
            guard let destination = segue.destination as? MultiplayerGameOverViewController else {return}
            destination.score = tapManager?.sequence.count
            destination.players = tapManager?.players
            destination.winner = tapManager?.winner
            destination.myTurn = tapManager?.myTurn
            destination.message = message
        }
    }
    
}
