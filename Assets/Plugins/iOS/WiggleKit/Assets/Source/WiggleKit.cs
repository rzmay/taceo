using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using System.Runtime.InteropServices;

public class WiggleKit : MonoBehaviour
{

	#region Declare external C interface

	#if UNITY_IOS && !UNITY_EDITOR
		[DllImport("__Internal")]
		private static extern void _wk_startHapticEngine();

		[DllImport("__Internal")]
		private static extern void _wk_startVibration();

		[DllImport("__Internal")]
		private static extern void _wk_startVibrationFromControlPoints(string intensityControlPoints, string sharpnessControlPoints);
	#endif

	#endregion

	#region Wrapped methods and properties

	public static void StartHapticEngine()
	{
		#if UNITY_IOS && !UNITY_EDITOR
			_wk_startHapticEngine();
		#endif
	}

	public static void StartVibration()
	{
		#if UNITY_IOS && !UNITY_EDITOR
			_wk_startVibration();
		#endif
	}

	public static void StartVibration(AnimationCurve intensityCurve, AnimationCurve sharpnessCurve, bool simpleControlPoints = false, float interpolationInterval = 0.05f)
	{
		// Get control points
		List<Dictionary<string, float>> intensityControlPoints = ControlPointsFromCurve(intensityCurve, simpleControlPoints, interpolationInterval);
		List<Dictionary<string, float>> sharpnessControlPoints = ControlPointsFromCurve(sharpnessCurve, simpleControlPoints, interpolationInterval);

		// Stringify dicts for passing to objective c (nasty solution)
		List<string> intensityStrings = StringifyDictionaries(intensityControlPoints);
		List<string> sharpnessStrings = StringifyDictionaries(sharpnessControlPoints);

		// Stringify lists as well, delimited by character "|"
		string intensityString = String.Join("|", intensityStrings.ToArray()).ToString();
		string sharpnessString = String.Join("|", sharpnessStrings.ToArray()).ToString();

		#if UNITY_IOS && !UNITY_EDITOR
			_wk_startVibrationFromControlPoints(intensityString, sharpnessString);
		#endif
	}

	#endregion

	#region Singleton implementation
	private static WiggleKit _instance;
	public static WiggleKit Instance {
		get {
			if (_instance == null) {
				var obj = new GameObject("WiggleKit");
				_instance = obj.AddComponent<WiggleKit>();
			}
			return _instance;
		}
	}

	void Awake() {
		if (_instance != null) {
			Destroy(gameObject);
			return;
		}

		WiggleKit.StartHapticEngine();
		DontDestroyOnLoad(gameObject);
	}
	#endregion

	#region Delegates
	public System.Action<string> onStartVibration;
	public System.Action<string> onStopVibration;
	public void OnStartVibration(string id)
	{
		onStartVibration?.Invoke(id);
	}

	public void OnStopVibration(string id)
	{
		onStopVibration?.Invoke(id);
	}

	public void OnApplicationFocus(bool hasFocus)
	{
		if (hasFocus) WiggleKit.StartHapticEngine();
	}

	#endregion

	#region Private Methods

	private static List<Dictionary<string, float>> ControlPointsFromCurve(AnimationCurve curve, bool simpleControlPoints, float interpolationInterval = 0.05f)
	{
		List<Dictionary<string, float>> controlPoints = new List<Dictionary<string, float>>();

		if (simpleControlPoints)
		{
			foreach (Keyframe key in curve.keys)
			{
				controlPoints.Add(
					new Dictionary<string, float>()
					{
						{"time", key.time},
						{"value", key.value}
					}
				);
			}
		}
		else
		{
			Keyframe lastframe = curve.keys[curve.keys.Length - 1];
			for (float i = 0; i <= lastframe.time; i += interpolationInterval)
			{
				controlPoints.Add(
					new Dictionary<string, float>()
					{
						{"time", i},
						{"value", curve.Evaluate(i)}
					}
				);
			}
		}

		return controlPoints;
	}

	private static List<string> StringifyDictionaries(List<Dictionary<string, float>> dicts)
	{
		List<string> list = new List<string>();

		foreach (Dictionary<string, float> dict in dicts)
		{
			string jsonString = $"{{\"time\":{dict["time"]},\"value\":{dict["value"]}}}";
			list.Add(jsonString);
		}

		return list;
	}

	#endregion
}
