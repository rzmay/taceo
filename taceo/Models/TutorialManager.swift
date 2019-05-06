//
//  tutorialManager.swift
//  taceo
//
//  Created by Lucas Kiewek on 4/29/19.
//  Copyright © 2019 Robert May. All rights reserved.
//

import Foundation

class TutorialManager {
    
    var current: Int
    var onEnd: ()->Void
    var sections: [()->Void]
    
    
    init(startAt: Int, completion: @escaping ()->Void) {
        current = startAt
        onEnd = completion
        sections = [()->Void]()
        
        setUpSections()
    }
    
    func playSection(_ section: Int){
        current = section
        print("Playing section \(section)")
        startPlaying(section: current, completion: onSectionEnd)
    }
    
    func onSectionEnd() {
        // Stop playing old section
        
        // Play next
        if (current < sections.count) {playSection(current+1)}
        else {onEnd()}
    }
    
    func startPlaying(section: Int, completion: @escaping ()->Void) {
        // Play the section
        sections[section]()
        
        // After playing
        completion()
    }
    
    func setUpSections() {
        func playSectionZero() {
            print("called 0")
        }
        sections[0] = playSectionZero
        
        func playSectionOne() {
            print("called 1")
        }
        sections[1] = playSectionOne
        
        func playSectionTwo() {
            print("called 2")
        }
        sections[2] = playSectionTwo
    }
    

    
    /*
     Tutorial:
     Swipe to skip a section of the tutorial,
     Press and hold to return to the home screen.
     
     Section 1:
     Taceo is a memory game.
     The goal is to remember the longest pattern of taps, swipes and long presses possible.
     
     Section 2:
     Each action has a corresponding vibration
     A tap feels like this:
     A swipe feels like this:
     And a long press feels like this
     
     There are also vibrations letting you know when a turn begins or ends:
     And a vibration letting you know the game is over:
     
     Section 3:
     Once the game begins, you will feel the "turn begins" vibration followed by the first action and its corresponding vibration
     Finally you will feel the "turn ends" vibration letting you know that it is your turn to recreate the given pattern
     
     Section 4:
     If you successfully recreate the pattern, you will feel the "turn ends" vibration.
     After this, the pattern will be repeated and a new action will be added to the pattern
     This will continue until you mess up
     
     Section 5:
     Tap to begin playing
     */
    
}
