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
        startReading()
    }
    
    func startReading() {
        recievingInput = false
        sequenceManager.add(tap: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: { [weak self] in
            self?.tapIndicationLabel.text = "✓ ✓ ✓"
            self?.tapIndicationLabel.textColor = TaceoColors.magenta
            guard let animate = self?.animate else {return}
            self?.sequenceManager.read(animation: animate) { [weak self] in
                self?.tapIndicationLabel.text = "✓"
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
                }
            }
        }
    }
    
    func animate(_ tap: TaceoTapType) {
        switch tap {
        case .short:
            tapIndicationLabel.text = "O"
        case .long:
            tapIndicationLabel.text = "O O O"
        case .swipe:
            tapIndicationLabel.text = "O O"
        }
    }
    
    func handleSwipe() {
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
    
}
