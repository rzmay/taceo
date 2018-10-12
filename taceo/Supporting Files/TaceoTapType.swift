//
//  TaceoTapTypes.swift
//  taceo
//
//  Created by Robert May on 10/11/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import Foundation

enum TaceoTapType {
    case short, long, swipe
    
    func vibration() -> TaceoVibrationControl {
        switch self {
        case .short:
            return TaceoVibrationControl.heavy
        case .long:
            return TaceoVibrationControl.nope
        case .swipe:
            return TaceoVibrationControl.warning
        }
    }
}
