//
//  ClassicGameOverViewController.swift
//  taceo
//
//  Created by Robert May on 10/13/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

class ClassicGameOverViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var score: Int?
    var sequence: [TaceoTapType]?
    var newHighScore: Bool = false
    var scoreRead = false
    var setScore = false
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional loading here
        guard let score = score else { return }
        
        var currentLabel = 0
        let oldHighScore = Int(CoreDataHelper.retrieveHighScore()?.score ?? 0)
        
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
                
                // Update high score label
                if currentLabel > oldHighScore {
                    self?.highScoreLabel.text = String(currentLabel)
                }
            }
            
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        if let highScore = CoreDataHelper.retrieveHighScore() {
            highScoreLabel.text = "\(highScore.score)"
        }
        
        guard let seq = sequence else {return}
        
        newHighScore = CoreDataHelper.HighScoreEditor.checkHighScore(with: score, sequence: seq)
        
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
        
        trySegue(withIdentifier: "playAgain")
        
    }
    
    @objc func handleRightSwipe(_ sender: UISwipeGestureRecognizer) {
        trySegue(withIdentifier: "classicToTitleScreen")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        if identifier == "classicToSequenceScreen" {
            
            guard let hc = CoreDataHelper.retrieveHighScore() else { return }
            let sequenceString = hc.sequence
            let sequence = sequenceString?.split(separator: ";").map({ (tapType) -> TaceoTapType in
                return TaceoSequenceManager.tapTypeFrom(string: String(tapType))
            })
            guard let destination = segue.destination as? ClassicSequenceViewController else { return }
            destination.sequence = sequence
        }
    }
    
    @objc func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        trySegue(withIdentifier: "classicToSequenceScreen")
    }
    
    @IBAction func unwindToGameOver(_ segue: UIStoryboardSegue) {
        
    }
    
    deinit {
        timer?.invalidate()
    }
    
}
