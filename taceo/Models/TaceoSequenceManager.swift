//
//  TapSequenceManager.swift
//  taceo
//
//  Created by Robert May on 10/12/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import Foundation
import Firebase

class TaceoSequenceManager {
    
    static var tapTypes = [TaceoTapType.short, TaceoTapType.long, TaceoTapType.swipe]
    
    class Classic: TapSequenceManager {
    
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
    
    class Multiplayer: TapSequenceManager {
        
        let db = Firestore.firestore()
        let myTurn = true
        var sequence = [TaceoTapType]()
        var index = 0
        var gameId = ""
        var lastData: [String: Any] = new [String: Any]()
        
        init () {
            // nothing has to happen here
        }
        
        func read(animation: @escaping (TaceoTapType) -> Void, completion: @escaping () -> Void) {
            // This will set up the listeners for the other player's taps when it is their turn
            db.collection("public-games").document(gameId).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                // set turn
                
            }
        }


        func add(tap: TaceoTapType?) {
            sequence.append(tap ?? TaceoSequenceManager.tapTypes[Int.random(in: 0..<TaceoSequenceManager.tapTypes.count)])
            // Listen for a change to the sequence in the database and change sequence
            
        }

        func input(tap: TaceoTapType) -> Bool? {
            // Check your taps with the sequence in the database and write new tap when ready
        }

    }
    
}
