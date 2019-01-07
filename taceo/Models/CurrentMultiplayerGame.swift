//
//  CurrentMultiplayerGame.swift
//  taceo
//
//  Created by Robert May on 1/3/19.
//  Copyright © 2019 Robert May. All rights reserved.
//

import Foundation
import Firebase

class CurrentMultiplayerGame {
    
    // MARK: - Properties
    var sequenceManager: TaceoSequenceManager.Multiplayer
    var documentReference: DocumentReference
    
    // MARK: - Singleton
    
    private static var _current: CurrentMultiplayerGame?
    
    // MARK: - Class methods
    
    static func closeCurrent() {
        guard let current = _current else {return}
        current.sequenceManager.gameOverListener(message: "A player has quit the game!")
    }
    
    static func setCurrent(manager: TaceoSequenceManager.Multiplayer, doc: DocumentReference) {
        _current = CurrentMultiplayerGame(manager: manager, doc: doc)
    }
    
    // MARK: - Init
    
    init(manager: TaceoSequenceManager.Multiplayer, doc: DocumentReference) {
        sequenceManager = manager
        documentReference = doc
    }
    
}
