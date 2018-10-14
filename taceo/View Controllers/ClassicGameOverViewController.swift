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
    
    var score: Int?
    var scoreRead = false
    var setScore = false
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional loading here
        guard let score = score else { return }
        
        var currentLabel = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
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
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
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
    
    deinit {
        timer?.invalidate()
    }
    
}
