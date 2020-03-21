//
//  WiggleKitNative.swift
//  WiggleKitUnity
//
//  Created by Robert May on 11/1/19.
//  Copyright © 2019 Robert May. All rights reserved.
//

import Foundation
import CoreHaptics


@available(iOS 13.0, *)
@objc public class WiggleKitNative: NSObject {

    @objc static let shared = WiggleKitNative()

    static func generateVibrationId(withLength length: Int) -> String {
            return ([Int](0..<length)).map({ _ in Int.random(in: 0..<10) }).reduce("", { previous, current in String(previous) + String(current)})
    }

    private var engine: CHHapticEngine?

    let kCallbackTarget = "WiggleKit"

    @objc override init() {
    	super.init()

    	// Start and setup engine
		startHapticEngine()

        // The engine stopped; print out why
        engine?.stoppedHandler = { e in
        	print("The engine stopped: \(e)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [weak self] in
        	print("The engine reset")

            do {
            	try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }

    @objc func startHapticEngine() {
		do {
        	if (engine == nil) { engine = try CHHapticEngine() }
        	try engine?.start()
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }

    @objc func startVibration() {
        // create a dull, strong haptic
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

        // create a curve that fades from 1 to 0 over one second
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)

        // use that curve to control the haptic strength
        let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, end], relativeTime: 0)

        // create a continuous haptic event starting immediately and lasting one second
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 1)

        playVibration(from: [event], curves: [parameter])
        //UnitySendMessage(kCallbackTarget, "OnStartRecording", "")
    }

    @objc func startVibration(intensity intensityControlPointsString: String, sharpness sharpnessControlPointsString: String) {
    	// Parse [String] from strings
        let intensityControlPoints: [String] = intensityControlPointsString.components(separatedBy: "|")
        let sharpnessControlPoints: [String] = sharpnessControlPointsString.components(separatedBy: "|")

        let (events, curves) = hapticEvents(
        	from: controlPoints(fromStrings: intensityControlPoints),
            controlPoints(fromStrings: sharpnessControlPoints)
        )

        playVibration(from: events, curves: curves)
    }

    private func controlPoints(fromStrings strings: [String]) -> [[String: Any]] {
        var controlPoints = [[String: Any]]()
        for string in strings {
            if let data = string.data(using: .utf8) {
                do {
                    guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { continue }
                    controlPoints.append(dict)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        return controlPoints
    }

    private func hapticEvents(from intensityControlPoints: [[String: Any]], _ sharpnessControlPoints: [[String: Any]]) -> (events: [CHHapticEvent], parameterCurves: [CHHapticParameterCurve]) {
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()

        // One event with curves to change values
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        var duration: Double = 0.0;

        // Get control points for value & sharpness
        var sharpnessPoints = [CHHapticParameterCurve.ControlPoint]()
        var intensityPoints = [CHHapticParameterCurve.ControlPoint]()

        var intensityLastTime: Double = 0.0
        for point in intensityControlPoints {
            // Get control point value & time
            let value = point["value"] as? Double ?? 1.0
            let time = point["time"] as? Double ?? intensityLastTime

            intensityPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: TimeInterval(time), value: Float(value)))

            intensityLastTime = time

            if (time > duration) { duration = time }
        }

        var sharpnessLastTime: Double = 0.0
        for point in sharpnessControlPoints {
            // Get control point value & time
            let value = point["value"] as? Double ?? 1.0
            let time = point["time"] as? Double ?? sharpnessLastTime

            sharpnessPoints.append(CHHapticParameterCurve.ControlPoint(relativeTime: TimeInterval(time), value: Float(value)))

            sharpnessLastTime = time

            if (time > duration) { duration = time }
        }

        let intensityCurve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: intensityPoints, relativeTime: 0.0)
        let sharpnessCurve = CHHapticParameterCurve(parameterID: .hapticSharpnessControl, controlPoints: sharpnessPoints, relativeTime: 0.0)
        curves = [intensityCurve, sharpnessCurve]

        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: TimeInterval(duration))
        events = [event]

        return (events: events, parameterCurves: curves)
    }

    @objc private func playVibration(from events: [CHHapticEvent], curves parameters: [CHHapticParameterCurve]) {
        // Make sure device is capable
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
        	print("Device does not support haptics!")

        	// Vibrate using fallback
        	WiggleKitFallbackNative.shared.startVibration()
        	return
        }
        guard let e = engine else {
        	print("Engine not found!")
        	return
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: parameters)
            let player = try e.makePlayer(with: pattern)
            let vibrationID = WiggleKitNative.generateVibrationId(withLength: 10)

            UnitySendMessage(kCallbackTarget, "OnStartVibration", vibrationID)

            try player.start(atTime: 0)

            DispatchQueue.main.asyncAfter(deadline: .now() + pattern.duration) { [weak self] in
                UnitySendMessage(self?.kCallbackTarget, "OnStopVibration", vibrationID)
            }
        } catch {
            assertionFailure("ERROR: WiggleKit: Something went wrong trying to play the vibration")
        }
    }
}
