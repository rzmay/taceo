//
//  TapSequenceManager.swift
//  taceo
//
//  Created by Robert May on 10/12/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import Foundation

protocol TapSequenceManager {

    var sequence: [TaceoTapType] {get}
    var index: Int {get}
    
    func add(tap: TaceoTapType?)
    func read(animation: @escaping (TaceoTapType) -> Void, completion: @escaping () -> Void)
    func input(tap: TaceoTapType) -> Bool?
    
}
