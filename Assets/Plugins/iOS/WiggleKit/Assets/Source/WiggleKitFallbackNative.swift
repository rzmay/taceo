//
//  WiggleKitFallbackNative.swift
//  Unity-iPhone
//
//  Created by Robert May on 11/4/19.
//

import Foundation
import AudioToolbox


@objc public class WiggleKitFallbackNative: NSObject {

    @objc static let shared = WiggleKitFallbackNative()

    let kCallbackTarget = "WiggleKit"

    @objc func startVibration() {
        // Just use default vibration; custom vibration not available


        UnitySendMessage(kCallbackTarget, "OnStartVibration", "")
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) { [weak self] in
            UnitySendMessage(self?.kCallbackTarget, "OnStopVibration", "")
        }
    }
}
