//
//  WiggleKitBridge.mm
//  WiggleKitUnity
//
//  Created by Robert May on 11/1/19.
//  Copyright © 2019 Robert May. All rights reserved.
//

#import <CoreHaptics/CoreHaptics.h>
#include "WiggleKitUnityBridge-Swift.h"


#pragma mark - C interface

NSString* CreateNSString (const char* string) {
  if (string)
      return [NSString stringWithUTF8String: string];
  else
      return [NSString stringWithUTF8String: ""];
}

extern "C" {

	void _wk_startHapticEngine() {
		if (@available(iOS 13.0, *)) {
			[[WiggleKitNative shared] startHapticEngine];
		}
	}

    void _wk_startVibration() {
        if (@available(iOS 13.0, *)) {
            [[WiggleKitNative shared] startVibration];
        } else {
            // Fallback on earlier versions
            [[WiggleKitFallbackNative shared] startVibration];
        }
    }

    void _wk_startVibrationFromControlPoints(const char* intensityControlPoints, const char* sharpnessControlPoints) {
        NSString* intensityCP = CreateNSString(intensityControlPoints);
        NSString* sharpnessCP = CreateNSString(sharpnessControlPoints);

        if (@available(iOS 13.0, *)) {
            [[WiggleKitNative shared] startVibrationWithIntensity:intensityCP sharpness:sharpnessCP];
        } else {
            // Fallback on earlier versions
            [[WiggleKitFallbackNative shared] startVibration];
        }
    }
}
