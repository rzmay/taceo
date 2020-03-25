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

	public TMP_Text highScoreLabel;

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

		highScoreLabel.text = saveState.highScore.ToString();

		LeanTouch.OnFingerTap += HandleTap;
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
				break;
			case AppState.Game:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, true);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			case AppState.PostGame:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, false);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			case AppState.Replay:
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				gameOverPanel.GetComponent<Animator>().SetBool(Hidden, true);
				replayPanel.GetComponent<Animator>().SetBool(Hidden, false);
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
}
