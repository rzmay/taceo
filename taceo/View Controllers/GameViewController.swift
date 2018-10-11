//
//  GameViewController.swift
//  taceo
//
//  Created by Robert May on 10/5/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    
    var audioSession = AVAudioSession()
    var recognizeLong = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    func handleSwipe() {
        print("swipe")
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
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if recognizeLong {
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
