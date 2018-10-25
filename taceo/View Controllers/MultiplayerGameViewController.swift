//
//  MultiplayerGameViewController.swift
//  taceo
//
//  Created by Robert May on 10/12/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit
import SocketIO

class MultiplayerGameViewController: UIViewController {
    
    var recognizeLong = true
    var privacyStatus: (priv: Bool, pass: String)?
    var nickname: String?
    let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
    var socket: SocketIOClient! = nil
    var gameId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUpSocket()
        
    }
    
    func setUpSocket() {
        
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            guard let name = self?.nickname,
                let privacy = self?.privacyStatus
                else { return }
            let emitData: [String: Any] = [
                "name": name,
                "private": privacy.priv,
                "password": privacy.pass
            ]
            self?.socket.emit("game", emitData)
        }
        
        socket.connect()
        
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
        socket.emit("tap")
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
