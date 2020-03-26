using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Util;

[CreateAssetMenu(fileName =  "New Gesture Vibration Set", menuName = "GestureVibrations")]
public class GestureVibrations : ScriptableObject
{
    [System.Serializable]
    public struct GestureVibration
    {
        public SequenceManager.Sequence.Gesture gesture;
        public VibrationData vibration;
    }
    
    [SerializeField]
    public List<GestureVibrations.GestureVibration> vibrations = new List<GestureVibrations.GestureVibration>();
    
}
