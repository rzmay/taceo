//
//  TapSequenceManager.swift
//  taceo
//
//  Created by Robert May on 10/12/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import Foundation

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
            var i = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [weak self] _ in
                readSequence[i].vibrate()
                
                if let tap = readSequence[i].tap() {
                    animation(tap)
                }
                
                i += 1
                if i >= readSequence.count {
                    self?.timer?.invalidate()
                    completion()
                }
            }
        }
        
        func input(tap: TaceoTapType) -> Bool? {
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
    
//    class Multiplayer: TapSequenceManager {
//
//        var sequence: [TaceoTapType]
//        var index: Int
//
//        init () {
//            // nothing has to happen here
//        }
//
//        func add(tap: TaceoTapType?) {
//            sequence.append(tap ?? TaceoSequenceManager.tapTypes[Int.random(in: 0..<TaceoSequenceManager.tapTypes.count)])
//        }
//
//        func read(completion: @escaping () -> Void) {
//            <#code#>
//        }
//
//        func input(tap: TaceoTapType) -> Bool? {
//            <#code#>
//        }
//
//    }
    
}