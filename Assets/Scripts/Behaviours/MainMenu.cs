using System.Collections;
using System.Collections.Generic;
using Lean.Touch;
using UnityEngine;

public class MainMenu : MonoBehaviour
{

	public enum AppState
	{
		MainMenu,
		Game,
		GameOver,
		Tutorial
	}

	public GameObject mainMenuPanel;

	// Start on main menu
	public static AppState state = AppState.MainMenu;

	private static readonly int Hidden = Animator.StringToHash("hidden");

	// Start is called before the first frame update
	void Start()
	{
		// Start on main menu
		state = AppState.MainMenu;

		Lean.Touch.LeanTouch.OnFingerTap += HandleTap;
	}

	// Update is called once per frame
	void Update()
	{

	}

	private void HandleTap(LeanFinger finger)
	{
		switch (state)
		{
			case AppState.MainMenu:
				state = AppState.Game;
				mainMenuPanel.GetComponent<Animator>().SetBool(Hidden, true);
				break;
			default:
				Debug.Log(state);
				break;
		}
	}
}
