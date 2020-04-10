using System.Collections;
using System.Collections.Generic;
using Lean.Touch;
using TMPro;
using UnityEngine;

public class MainMenu : MonoBehaviour
{

	public enum AppState
	{
		MainMenu,
		Game,
		GameOver,
		PostGame,
		Replay,
		Tutorial
	}

	public GameObject mainMenuPanel;
	public GameObject gameOverPanel;
	public GameObject replayPanel;
	public GameObject tutorialPanel;

	public TMP_Text highScoreLabel;

	private float _inputStart;

	// Start on main menu
	public static AppState state = AppState.MainMenu;
	public static SaveState saveState;

	private static readonly int Hidden = Animator.StringToHash("hidden");

	// Start is called before the first frame update
	void Start()
	{
		// Start on main menu
		state = AppState.MainMenu;
		saveState = SaveSystem.LoadData();

		_inputStart = Time.time;

		highScoreLabel.text = saveState.highScore.ToString();

		LeanTouch.OnFingerTap += HandleTap;
		LeanTouch.OnFingerSwipe += HandleSwipe;
		
		// Show tutorial on first open
		if (!saveState.hasSeenTutorial)
		{
			state = AppState.Tutorial;
		}
	}

	// Update is called once per frame
	void Update()
	{
		switch (state)
		{
			case AppState.MainMenu:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, false);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, true);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, true);
				tutorialPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			case AppState.Game:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, true);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, true);
				tutorialPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			case AppState.PostGame:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, false);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, true);
				tutorialPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			case AppState.Replay:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, true);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, false);
				tutorialPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			case AppState.Tutorial:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, true);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, true);
				tutorialPanel.GetComponent<Animator>().SetBool(Hidden, false);
				break;
		}
	}

	private void HandleTap(LeanFinger finger)
	{
		switch (state)
		{
			case AppState.MainMenu:
				state = AppState.Game;
				break;
			default:
				// Debug.Log(state);
				break;
		}
	}
	
	private void HandleSwipe(LeanFinger finger)
	{
		if (state == AppState.MainMenu)
		{
			// Make sure swipe did not begin before input
			if (finger.Age < Time.time - _inputStart)
			{
				float angle = Mathf.Atan2(finger.SwipeScaledDelta.y, finger.SwipeScaledDelta.x);
				if (Mathf.Abs(Mathf.Cos(angle)) > 0.8)
				{
					// pass
				}
				else if (Mathf.Abs(Mathf.Sin(angle)) > 0.8)
				{
					// If positive, swipe up
					if (Mathf.Sin(angle) > 0)
					{
						state = AppState.Tutorial;
					}
				}
			}
		}
	}
}
