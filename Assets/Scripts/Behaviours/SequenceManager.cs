using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Lean.Touch;
using TMPro;
using UnityEngine;
using UnityEngine.PlayerLoop;
using Util;
using Random = UnityEngine.Random;

public class SequenceManager : MonoBehaviour
{

	public static SequenceManager unique;

	[System.Serializable]
	public class Sequence
	{

		public enum Gesture
		{
			Tap,
			Long,
			SwipeVertical,
			SwipeHorizontal,
		}

		private List<Gesture> _gestures = new List<Gesture>();

		public Gesture[] Gestures
		{
			get => _gestures.ToArray();
		}

		public Sequence()
		{
			_gestures = new List<Gesture>();
		}

		public Sequence(List<Gesture> list)
		{
			_gestures = list;
		}

		public void AddGesture()
		{
			int values = Enum.GetValues(typeof(Gesture)).Length;
			_gestures.Add((Gesture)Random.Range(0, values));
		}

	}

	[Header("Vibrations")]
	public GestureVibrations gestureVibrations;
	public VibrationData roundStart;
	public VibrationData gameOver;
	
	[Space]
	public Sequence sequence;

	[Space] [Header("Appearance")]
	public AnimatedLogo logo;
	public ParticleSystem roundStartParticle;
	public ParticleSystem gameOverParticle;
	
	[Space] [Header("Debug")]
	public TMP_Text debugText;

	[HideInInspector]
	public int lastHighScore = 0;

	private int _sequenceIndex = 0;

	private float _inputStart;
	private bool _awaitingInput = false;

	private bool _isReplaying = false;

	private float _vibrationTime;
	private AnimationCurve _vibrationCurve = AnimationCurve.Constant(0, 0, 0);

	private MainMenu.AppState _state;

	// Start is called before the first frame update
    void Start()
    {
	    unique = this;

	    _state = MainMenu.AppState.MainMenu;

	    LeanTouch.OnFingerTap += HandleTap;
	    LeanTouch.OnFingerUp += HandleHold;
	    LeanTouch.OnFingerSwipe += HandleSwipe;
    }

    // Update is called once per frame
    void Update()
    {
	    // On state change
	    if (_state != MainMenu.state)
	    {
		    _state = MainMenu.state;
		    switch (_state)
		    {
			    case MainMenu.AppState.Game:
					StartGame();
					break;
			    case MainMenu.AppState.Replay:
				    StartReplay();
				    break;
			    default:
				    Debug.Log(_state);
				    break;
		    }
	    }

	    // Update logo
	    float t = Time.time - _vibrationTime;
	    if (t < _vibrationCurve.keys.Last().time)
	    {
		    LogoBall.vibrationIntensity = _vibrationCurve.Evaluate(t);
	    }
	    else
	    {
		    LogoBall.vibrationIntensity = 0.0f;
	    }
    }

    private void StartGame()
    {
	    _isReplaying = false;
	    
	    // Reset sequence
	    sequence = new Sequence();

	    // Load high score before game starts to keep a record if high score is beaten
	    lastHighScore = MainMenu.saveState.highScore;

	    StartCoroutine(StartRound());
    }
    
    private void StartReplay()
    {
	    _isReplaying = true;
	    
	    // Reset sequence
	    sequence = MainMenu.saveState.sequence;

	    // Load high score before game starts to keep a record if high score is beaten
	    lastHighScore = MainMenu.saveState.highScore;

	    StartCoroutine(StartRound());
    }

    private IEnumerator StartRound()
    {
	    _awaitingInput = false;
	    _sequenceIndex = 0;

	    // Feedback
	    yield return new WaitForSeconds(1);
	    debugText.text = "Round Start";
	    logo.SetState(AnimatedLogo.LogoState.Default);
	    roundStart.Start();
	    roundStartParticle.Play();
	    
	    // Reading
	    yield return new WaitForSeconds(2);
	    logo.SetState(AnimatedLogo.LogoState.Focus);
	    sequence.AddGesture();
	    foreach (Sequence.Gesture gesture in sequence.Gestures)
	    {
		    GestureVibrations.GestureVibration vibration = TapVibrationFromGesture(gesture);
		    debugText.text = vibration.gesture.ToString();
		    vibration.vibration.Start();
		    LogoVibration(vibration.vibration);

		    yield return new WaitForSeconds(1.5f);
	    }

	    // "Your turn" feedback
	    logo.SetState(AnimatedLogo.LogoState.Inverted);
	    debugText.text = "Your turn";
	    _awaitingInput = true;
	    _inputStart = Time.time;
	    roundStart.Start();
    }

    private GestureVibrations.GestureVibration TapVibrationFromGesture(Sequence.Gesture gesture)
    {
	    GestureVibrations.GestureVibration vibration = gestureVibrations.vibrations.Where(v => v.gesture == gesture).ToArray()[0];
	    return vibration;
    }

    private IEnumerator CheckGesture(Sequence.Gesture gesture)
    {
	    if (gesture == sequence.Gestures[_sequenceIndex])
	    {
		    GestureVibrations.GestureVibration vibration = TapVibrationFromGesture(gesture);
		    debugText.text = vibration.gesture.ToString();
		    vibration.vibration.Start();

		    _sequenceIndex += 1;

		    // If round is over
		    if (_sequenceIndex == sequence.Gestures.Length)
		    {
			    if (!_isReplaying)
			    {
				    _awaitingInput = false;
				    StartCoroutine(StartRound());
			    }
			    else
			    {
				    roundStart.Start();
				    MainMenu.state = MainMenu.AppState.GameOver;
				    
				    yield return new WaitForSeconds(2);
				    debugText.text = "";
				    MainMenu.state = MainMenu.AppState.PostGame;
			    }
		    }
	    }
	    else
	    {
		    // Game is over
		    _awaitingInput = false;

		    if (!_isReplaying) SaveData();

		    debugText.text = "Game Over";
		    MainMenu.state = MainMenu.AppState.GameOver;
		    gameOverParticle.Play();
		    gameOver.Start();

		    // Wait before exiting game view
		    yield return new WaitForSeconds(2);
		    debugText.text = "";
		    MainMenu.state = MainMenu.AppState.PostGame;
	    }
    }

    private void HandleTap(LeanFinger finger)
    {
	    if (_state == MainMenu.AppState.Game || _state == MainMenu.AppState.Replay)
	    {
		    if (_awaitingInput)
		    {
			    StartCoroutine(CheckGesture(Sequence.Gesture.Tap));
		    }
	    }
    }

    private void HandleHold(LeanFinger finger)
    {
	    if (_state == MainMenu.AppState.Game || _state == MainMenu.AppState.Replay)
	    {
		    if (_awaitingInput)
		    {
			    // If longer than tap, not a swipe, and younger than the beginning of input
			    if (finger.Old && !finger.Swipe && finger.Age < Time.time - _inputStart)
			    {
				    StartCoroutine(CheckGesture(Sequence.Gesture.Long));
			    }
		    }
	    }
    }

    private void HandleSwipe(LeanFinger finger)
    {
	    if (_state == MainMenu.AppState.Game || _state == MainMenu.AppState.Replay)
	    {
		    // Make sure swipe did not begin before input
		    if (_awaitingInput && finger.Age < Time.time - _inputStart)
		    {
			    float angle = Mathf.Atan2(finger.SwipeScaledDelta.y, finger.SwipeScaledDelta.x);
			    Debug.Log($"Vector: {finger.SwipeScaledDelta}, Angle: {angle}");
			    Debug.Log($"Cosine: {Mathf.Cos(angle)}, Sine: {Mathf.Sin(angle)}");
			    if (Mathf.Abs(Mathf.Cos(angle)) > 0.8)
			    {
				    StartCoroutine(CheckGesture(Sequence.Gesture.SwipeHorizontal));
			    }
			    else if (Mathf.Abs(Mathf.Sin(angle)) > 0.8)
			    {
				    StartCoroutine(CheckGesture(Sequence.Gesture.SwipeVertical));
			    }
		    }
	    }
    }

    private void LogoVibration(VibrationData vibration)
    {
	    _vibrationTime = Time.time;
	    _vibrationCurve = vibration.intensityCurve;
    }

    private void SaveData()
    {
	    if (sequence.Gestures.Length > MainMenu.saveState.highScore)
	    {
		    SaveState newSave = new SaveState(
			    sequence.Gestures.Length - 1,
			    sequence
			);

		    MainMenu.saveState = newSave;
		    SaveSystem.SaveData(MainMenu.saveState);
	    }
    }
}
