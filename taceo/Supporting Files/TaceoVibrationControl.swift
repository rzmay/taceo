//
//  BoomStyle.swift
//  taceo
//
//  Created by Robert May on 10/5/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

enum TaceoVibrationControl {
    case pop
    case peek
    case nope
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case selection
    case oldSchool
    
    func vibrate() {
        
        switch self {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            
        case .pop:
            AudioServicesPlaySystemSound(1519)
            
        case .peek:
            AudioServicesPlaySystemSound(1520)
            
        case .nope:
            AudioServicesPlaySystemSound(1521)
            
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func tap() -> TaceoTapType? {
        
        switch self {
        case .heavy:
            return TaceoTapType.short
            
        case .warning:
            return TaceoTapType.swipe
            
        case .nope:
            return TaceoTapType.long
            
        default:
            return nil
        }
    }
}
