//
//  GameViewController.swift
//  taceo
//
//  Created by Robert May on 10/5/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit

class ClassicGameViewController: UIViewController {
    
    @IBOutlet weak var tapIndicationLabel: UILabel!
    
    var sequenceManager = TaceoSequenceManager.Classic()
    var recognizeLong = true
    var recievingInput = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tapIndicationLabel.text = ""
        
        // Manually set up swipe actions;
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset for new game
        
        sequenceManager = TaceoSequenceManager.Classic()
        recognizeLong = true
        recievingInput = false
        
        startReading()
    }
    
    func startReading() {
        recievingInput = false
        sequenceManager.add(tap: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let count = self?.sequenceManager.sequence.count else {return}
            self?.tapIndicationLabel.text = count > 1 ? "correct" : "game start!"
            self?.tapIndicationLabel.textColor = TaceoColors.magenta
            guard let animate = self?.animate else {return}
            self?.sequenceManager.read(animation: animate) { [weak self] in
                self?.tapIndicationLabel.text = "your turn"
                self?.tapIndicationLabel.textColor = TaceoColors.gold
                self?.recievingInput = true
            }
        })
    }
    
    func followInput(for tap: TaceoTapType) {
        if recievingInput {
            animate(tap)
            let won = sequenceManager.input(tap: tap)
            if let response = won {
                if response {
                    startReading()
                } else {
                    tapIndicationLabel.text = "X"
                    recievingInput = false
                    
                    var repeats = 0
                    weak var timer: Timer?
                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                        
                        repeats += 1
                        if repeats > 3 {
                            timer?.invalidate()
                            self?.tapIndicationLabel.text = ""
                            self?.performSegue(withIdentifier: "gameOver", sender: nil)
                        } else {
                            TaceoVibrationControl.error.vibrate()
                        }
                    }
                }
            }
        }
    }
    
    func animate(_ tap: TaceoTapType) {
        switch tap {
        case .short:
            tapIndicationLabel.text = "tap"
        case .long:
            tapIndicationLabel.text = "hold"
        case .swipe:
            tapIndicationLabel.text = "swipe"
        }
    }
    
    @objc func handleSwipe() {
        print("swipe")
        followInput(for: .swipe)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        recognizeLong = true
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        recognizeLong = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        if identifier == "gameOver" {
            guard let destination = segue.destination as? ClassicGameOverViewController else { return }
            destination.score = sequenceManager.sequence.count - 1
        }
    }
    
    @IBAction func unwindToClassicGame(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        print("tap")
        followInput(for: .short)
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if recognizeLong {
            followInput(for: .long)
            print("long press")
            recognizeLong = false
        }
    }
    
}
