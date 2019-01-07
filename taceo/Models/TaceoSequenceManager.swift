//
//  TapSequenceManager.swift
//  taceo
//
//  Created by Robert May on 10/12/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class TaceoSequenceManager {
    
    static var tapTypes = [TaceoTapType.short, TaceoTapType.long, TaceoTapType.swipe]
    
    class Classic {
    
        var sequence = [TaceoTapType]()
        var index = 0
        
        weak var timer: Timer?
        
        init () {
            // nothing has to happen here
        }
        
        func add(tap: TaceoTapType?) {
            guard let tap = tap else {
                sequence.append(TaceoSequenceManager.tapTypes[Int.random(in: 0..<TaceoSequenceManager.tapTypes.count)])
                return
            }
            
            sequence.append(tap)
        }
        
        func read(animation: @escaping (TaceoTapType) -> Void, completion: @escaping () -> Void) {
            var readSequence: [TaceoVibrationControl] = [.error]
            for tap in sequence {
                readSequence.append(tap.vibration())
            }
            readSequence.append(.error)
            timer?.invalidate()
            // i is not the index of the read sequence, but the element number
            var i = 1
            timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [weak self] _ in
                
                if i >= readSequence.count {
                    self?.timer?.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        readSequence[readSequence.count - 1].vibrate()
                        
                        completion()
                    }
                } else {
                    if let tap = readSequence[i-1].tap() {
                        animation(tap)
                    }
                    readSequence[i-1].vibrate()
                }
                
                i += 1
            }
        }
        
        func input(tap: TaceoTapType) -> Bool? {
            tap.vibration().vibrate()
            if sequence[index] == tap {
                index += 1
                if index >= sequence.count {
                    index = 0
                    return true
                } else {
                    return nil
                }
            } else {
                return false
            }
        }
        
        deinit {
            timer?.invalidate()
        }
    }
    
    class Multiplayer {
        
        let db = Firestore.firestore()
        var myTurn = true
        var sequence = [TaceoTapType]()
        var index = 0
        var gameId = ""
        var gamePrivacy: [String: Any] = [
            "private": false,
            "password": ""
        ]
        var lastData: [String: Any] = [String: Any]()
        var gameOver = false
        var nickname = ""
        var joinError = ""
        var player = 1
        var players = [String]()
        var gameStarted = false
        var animate: (TaceoTapType) -> Void
        var rootListener: ListenerRegistration?
        var gameStartListener: ListenerRegistration?
        var winner = 0
        var inputRegistered = true;
        var afkTimer: Timer?
        
        weak var viewController: MultiplayerGameViewController?
        
        init (client name: String, privacy: (priv: Bool, pass: String), animation: @escaping (TaceoTapType) -> Void) {
            nickname = name
            animate = animation
            gamePrivacy = [
                "private": privacy.priv,
                "password": privacy.pass
            ]
            players.append(nickname)
            // Create or join game
            
            // If public, check game-ids/public/pending to see if there are any unjoined games
            // If private, join or create game
            guard let privacy = gamePrivacy["private"] as? Bool else {return}
            print(privacy)
            if !privacy {
                db.collection("public").document("game-ids").getDocument { [weak self] (document, error) in
                    guard let document = document,
                        document.exists
                        else {
                            print("Document does not exist")
                            // Create pending room
                            self?.createGame(privacy: privacy)
                            return
                        }
                    guard let data = document.data(),
                        let pending = data["pending"] as? [String]
                        else { return }
                    self?.joinPublicGame(from: pending)
                }
            } else {
                guard let password = gamePrivacy["password"] as? String else {return}
                joinGame(withId: password) { [weak self] success in
                    if success {
                        // Set player 2
                        self?.player = 1
                        // Start game
                        self?.startGame()
                    } else {
                        // If failed because game is full, go back to creation screen
                        // If failed because game does not exist, create game
                        
                        guard let document = self?.db.collection("private").document(password) else {return}
                        document.getDocument { [weak self] (document, error) in
                            guard let document = document,
                                document.exists
                                else {
                                    print("Document does not exist")
                                    // create game
                                    self?.createGame(privacy: true, password: password)
                                    return
                            }
                            guard let data = document.data(),
                                let full = data["full"] as? Bool
                                else { return }
                            // return to creation screen with appropriate error message
                            self?.returnToCreation(with: full ? "That game is already full" : "An unknown error occured")
                        }
                        
                    }
                }
            }
        }
        
        func joinPublicGame(from pending: [String]) {
            if pending.count > 0 {
                joinGame(withId: pending[0]) { [weak self] success in
                    if !success {
                        // If failed, get pending list again and filter out failed id
                        self?.db.collection("public").document("game-ids").getDocument { [weak self] (document, error) in
                            guard let document = document,
                                document.exists
                                else {
                                    print("Document does not exist")
                                    return
                            }
                            guard let data = document.data(),
                                let newPending = data["pending"] as? [String]
                                else { return }
                            let filteredPending = newPending.filter { $0 != pending[0] }
                            self?.joinPublicGame(from: filteredPending)
                        }
                    } else {
                        // Set player 2
                        self?.player = 1
                        // If success, set up for game start
                        self?.startGame()
                    }
                }
            } else {
                // Create pending room
                guard let privacy = gamePrivacy["private"] as? Bool else {return}
                createGame(privacy: privacy)
            }
        }
        
        func createGame(privacy: Bool, password: String = "none") {
            let collection = db.collection(privacy ? "private" : "public")
            collection.document("game-ids").getDocument { [weak self] (document, error) in
                guard let document = document,
                    document.exists
                    else {
                        print("Document does not exist")
                        // No games exist; Create new game
                        guard let game = password == "none" ?  self?.randomGameId(ids: [String]()): password else {return}
                        self?.gameId = game
                        
                        self?.writeGameData(collection: collection, gameId: game)
                        return
                }
                // Set new id
                guard let data = document.data(),
                    let ids = data["ids"] as? [String]
                    else {return}
                guard let game = password == "none" ?  self?.randomGameId(ids: ids): password else {return}
                self?.gameId = game
                
                self?.writeGameData(collection: collection, gameId: game)
            }
        }
        
        private func writeGameData(collection: CollectionReference, gameId: String) {
            // Data to be written to document
            let docData: [String: Any] = [
                "full": false,
                "players": [nickname],
                "sequence": [],
                "last-tap": NSNull(),
                "turn": 0,
                "game-over": false
            ]
            
            // Write data and add game id to appropriate id lists
            collection.document(gameId).setData(docData) { [weak self] err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    // Check if doc exists, if so update, if not write
                    let doc = collection.document("game-ids")
                    doc.getDocument { (document, error) in
                        guard let document = document else { return }
                        if document.exists {
                            doc.updateData([
                                "pending": FieldValue.arrayUnion([gameId]),
                                "ids": FieldValue.arrayUnion([gameId])
                            ])
                        } else {
                            doc.setData([
                                "pending": FieldValue.arrayUnion([gameId]),
                                "ids": FieldValue.arrayUnion([gameId])
                            ])
                        }
                    }
                    // Set player 1
                    self?.player = 0
                    // Start game
                    self?.startGame()
                }
            }
        }
        
        func joinGame(withId id: String, completion: @escaping (Bool) -> Void) {
            let game = db.collection(publicityString()).document(id)
            game.getDocument { [weak self] (document, error) in
                guard let document = document,
                    document.exists
                    else {
                        print("Document does not exist")
                        completion(false)
                        return
                }
                guard let data = document.data(),
                    let full = data["full"] as? Bool,
                    let nickname = self?.nickname
                    else {return}
                
                if !full {
                    game.updateData([
                        "players": FieldValue.arrayUnion([nickname]),
                        "full": true
                    ]) { err in
                        if let err = err {
                            print(err.localizedDescription)
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } else {
                    completion(false)
                }
                
            }
        }
        
        func startGame() {
            // Always set up listeners first
            setUpListeners()
            // If I am player 1, wait for player 2 to join
            if player == 0 {
                let publicity = publicityString()
                let doc = db.collection(publicity).document(gameId)
                let id = gameId
                gameStartListener = doc.addSnapshotListener { [weak self] documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    guard let data = document.data() else {
                        print("Document data was empty.")
                        return
                    }
                    guard let full = data["full"] as? Bool else {return}
                    if full {
                        // Make game start vibration, send your own first tap
                        TaceoVibrationControl.error.vibrate()
                        self?.displaySequenceBeginning()
                        self?.gameStarted = true
                        // Remove listener
                        self?.removeGameStartListener()
                        // Remove from pending ids if public
                        self?.db.collection(publicity).document("game-ids").updateData([
                            "pending": FieldValue.arrayRemove([id])
                        ])
                    }
                }
            } else {
                // If I am player 2, make game start vibration; listeners will tell when to react
                TaceoVibrationControl.error.vibrate()
                displaySequenceBeginning()
                gameStarted = true
            }
            // Set current multiplayer game
            CurrentMultiplayerGame.setCurrent(manager: self, doc: db.collection(publicityString()).document(gameId))
        }
        
        func removeGameStartListener() {
            gameStartListener?.remove()
        }
        
        func setUpListeners() {
            // This will set up the listeners for the other player's taps when it is their turn
            rootListener = db.collection(publicityString()).document(gameId).addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                // call appropriate listeners
                guard let gameIsPrivate = self?.gamePrivacy["private"] as? Bool,
                    let lastData = self?.lastData,
                    let players = data["players"] as? [String],
                    let turn = data["turn"] as? Int,
                    let sequence = data["sequence"] as? [String],
                    let tap = data["last-tap"] as? String,
                    let gameOver = data["game-over"] as? Bool,
                    let lastPlayers = lastData["players"] as? [String],
                    let lastTurn = lastData["turn"] as? Int,
                    let lastSequence = lastData["sequence"] as? [String],
                    let lastTap = lastData["last-tap"] as? String,
                    let lastGameOver = lastData["game-over"] as? Bool
                    else {return}
                
                if (players != lastPlayers) {
                    self?.playerListener(last: lastPlayers, new: players)
                }
                
                if (turn != lastTurn) {
                    self?.turnListener(new: turn)
                }
                
                if (sequence != lastSequence) {
                    self?.sequenceListener(last: lastSequence, new: sequence)
                }
                
                if (tap != lastTap) {
                    self?.lastTapListener(last: lastTap, new: tap)
                }
                
                if (gameOver != lastGameOver && gameOver == true) {
                    self?.gameOverListener(message: "Someone messed up the sequence!")
                }
                
                self?.lastData = data
                
            }
            
        }
        
        func returnToCreation(with message: String) {
            // return to creation screen
            joinError = message
            viewController?.returnToCreation()
        }
        
        func playerListener(last lastPlayers: [String], new newPlayers: [String]) {
            // If game was full and is no longer full, end game
            if newPlayers.count == 1 && lastPlayers.count == 2 {
                gameOverListener(message: "A player left the game!")
            }
            players = newPlayers
        }
        
        func gameOverListener(message: String) {
            // Only execute if not already executed
            if gameOver == false {
                gameOver = true
            } else {
                return
            }
            // Remove yourself from players
            let doc = db.collection(publicityString()).document(gameId)
            doc.updateData([
                "players": FieldValue.arrayRemove([nickname])
            ])
            // Stop listening, delete room
            rootListener?.remove()
            doc.delete() { err in
                if let err = err {
                    print("Error deleting document: \(err)")
                } else {
                    print("Document successfully deleted!")
                }
            }
            // Remove id from lists
            db.collection(publicityString()).document("game-ids").updateData([
                "pending": FieldValue.arrayRemove([gameId]),
                "ids": FieldValue.arrayRemove([gameId])
            ])
            // Set winner; If the game ended on my turn, I lost
            winner = myTurn ? 1 - player: player
            // View controller will send players to game over screen with
            // players, sequence, myTurn, & winner
            viewController?.endGame(message: message)
        }
        
        func turnListener(new turn: Int) {
            // Turn beginning or ending; play starting vibration
            TaceoVibrationControl.error.vibrate()
            if turn == player {
                myTurn = true
                viewController?.changeColor(to: 0)
            } else {
                viewController?.changeColor(to: 1)
                myTurn = false
            }
            displaySequenceBeginning()
        }
        
        func displaySequenceBeginning() {
            viewController?.tapIndicationLabel.text = "✔︎✔︎✔︎"
            print("displaySequenceBeginnin")
        }
        
        func sequenceListener(last lastSequence: [String], new newSequence: [String]) {
            // If the sequence has been appended to (should always resolve to true), set sequence
            if lastSequence.count < newSequence.count {
                sequence = newSequence.map({ TaceoSequenceManager.tapTypeFrom(string: $0) })
            }
        }
        
        func lastTapListener(last lastTap: String, new newTap: String) {
            // Read if not my own tap; If it is my own, it will have already been read
            if !myTurn {
                animate(TaceoSequenceManager.tapTypeFrom(string: newTap))
            }
            // Someone has tapped; reset afk timeout
            setUpAFKTimeout()
        }

        func input(tap: TaceoTapType) {
            // Check your taps with the sequence in the database and write new tap when ready
            if myTurn && gameStarted && inputRegistered {
                // Do not allow input until input has been set
                inputRegistered = false
                let completion: ((Error?)) -> () =  { [weak self] err in
                    self?.inputRegistered = true
                }
                let doc = db.collection(publicityString()).document(gameId)

                // If index > sequence.count - 1 (One has completed the sequence), upload the input and switch turns
                // Otherwise, check if the input is what it should be and break if not, increment index, upload tap & switch turn
                if index > sequence.count - 1 {
                    // Upload tap, switch turn
                    doc.setData([
                        "sequence": FieldValue.arrayUnion([tap.toString()]),
                        "last-tap": tap.toString(),
                        "turn": 1 - player
                    ]) { err in
                        completion(err)
                    }
                } else {
                    // Upload tap as last-tap
                    doc.setData([
                        "last-tap": tap.toString()
                    ]) { [weak self] err in
                        guard let index = self?.index,
                            let sequence = self?.sequence
                            else {return}
                        if tap == sequence[index] {
                            self?.index += 1
                            completion(err)
                        } else {
                            // End game; Upload true to game-over
                            doc.setData([
                                "game-over": true
                            ]) { deepErr in
                                completion(deepErr)
                            }
                        }
                    }
                }
            }
        }
        
        func setUpAFKTimeout() {
            // Stop previous timer
            afkTimer?.invalidate()
            // Wait for a minute before ending game;
            // If either player is AFK for this long, the other should not have to wait. The game must be over
            afkTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { [weak self] timer in
                guard let player = self?.player,
                    let players = self?.players,
                    let myTurn = self?.myTurn
                    else {return}
                self?.gameOverListener(message: myTurn ? "You were afk for too long!" : "\(players[1-player]) was afk for too long!")
            }
        }
        
        private func randomGameId(ids: [String]) -> String {
            let length = 10
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let id = "game-" + String((0...length-1).map{ _ in letters.randomElement()! })
            if ids.contains(id) {
                return randomGameId(ids: ids)
            } else {
                return id
            }
        }
        
        private func publicityString() -> String {
            guard let privacy = gamePrivacy["private"] as? Bool else {return "public"}
            return privacy ? "private" : "public"
        }
        
        deinit {
            // Remove all listeners & delete room
            afkTimer?.invalidate()
            removeGameStartListener()
            rootListener?.remove()
            gameOverListener(message: "You left the game!")
        }
        
    }
    
    static func tapTypeFrom(string: String) -> TaceoTapType {
        switch string {
        case "short":
            return .short
        case "long":
            return .long
        case "swipe":
            return .swipe
        default:
            fatalError("Unexpected tap type: \(string)")
        }
    }
    
}
