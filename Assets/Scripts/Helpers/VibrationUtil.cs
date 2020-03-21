using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Util
{

	[System.Serializable]
	public class VibrationData
	{
		public AnimationCurve intensityCurve;
		public AnimationCurve sharpnessCurve;

		public void Start()
		{
			WiggleKit.StartVibration(intensityCurve, sharpnessCurve);
		}

		public void Start(float scale)
		{
			WiggleKit.StartVibration(
				ScaleCurve(intensityCurve, scale),
				ScaleCurve(sharpnessCurve, scale)
			);
		}

		public void Start(float intensityScale, float sharpnessScale)
		{
			WiggleKit.StartVibration(
				ScaleCurve(intensityCurve, intensityScale),
				ScaleCurve(sharpnessCurve, sharpnessScale)
			);
		}

		private AnimationCurve ScaleCurve(AnimationCurve curve, float scale)
		{
			// Scale value, not time
			Keyframe[] keyframes = curve.keys;

			// Can't use foreach; mutable reference required
			for (int i = 0; i < keyframes.Length; i++)
			{
				keyframes[i].value *= scale;
			}

			return new AnimationCurve(keyframes);
		}
	}

}
