//
//  tutorialViewController.swift
//  taceo
//
//  Created by Lucas Kiewek on 10/23/18.
//  Copyright © 2018 Lucas Kiewek. All rights reserved.
//
import Foundation
import UIKit

class TutorialViewController: UIViewController {
    
    var sequence: [TaceoTapType]?
    var tutorialManager: TutorialManager?
    
    @IBOutlet var frameView: UIView!
    @IBOutlet weak var frameInsideView: UIView!
    @IBOutlet weak var tapIndicationLabel: UILabel!
    
    
    var sequenceManager = TaceoSequenceManager.Classic()
    var recognizeLong = true
    var recievingInput = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tapIndicationLabel.text = ""
        frameInsideView.layer.cornerRadius = 20
        frameView.layer.cornerRadius = 20
        
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
        
        beginTutorial()
        
    }
    
    func followInput(for tap: TaceoTapType) {
        if !recievingInput {return}
        if tap == .long {
            homeSegue()
        }
        if tap == .swipe {
            tutorialManager?.onSectionEnd()
        }
    }
    
    func beginTutorial() {
        tutorialManager = TutorialManager(startAt: 0) { [weak self] in
            self?.homeSegue()
        }
        tutorialManager?.playSection(0)
    }
    
    func homeSegue() {
        performSegue(withIdentifier: "tutorialOver", sender: self)
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        guard let identifier = segue.identifier else { return }
//
//        if identifier == "gameOver" {
//            guard let destination = segue.destination as? ClassicGameOverViewController else { return }
//            destination.score = sequenceManager.sequence.count - 1
//            destination.sequence = sequenceManager.sequence
//        }
//    }

