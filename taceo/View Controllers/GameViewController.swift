//
//  GameViewController.swift
//  taceo
//
//  Created by Robert May on 10/5/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit
import AudioToolbox

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func vibrate(at weight: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: weight)
        generator.impactOccurred()
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        
    }
    
}
