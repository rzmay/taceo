﻿using System.Collections;
using System.Collections.Generic;
using Lean.Touch;
using TMPro;
using UnityEngine;
using Util;

public class GameOverMenu : MonoBehaviour
{

	public TMP_Text scoreLabel;
	public VibrationData countVibration;

	private bool _completedCounting;

	private MainMenu.AppState _state;
	private Animator _scoreAnimator;

	private static readonly int Change = Animator.StringToHash("Change");
	private static readonly int HighScore = Animator.StringToHash("HighScore");

	// Start is called before the first frame update
    void Start()
    {
	    _state = MainMenu.AppState.MainMenu;
	    _scoreAnimator = scoreLabel.GetComponent<Animator>();

	    LeanTouch.OnFingerTap += HandleTap;
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
			    case MainMenu.AppState.PostGame:
				    StartCoroutine(CountScore());
				    break;
			    default:
				    break;
		    }
	    }
    }

    private IEnumerator CountScore()
    {
	    _completedCounting = false;
	    _scoreAnimator.SetBool(HighScore, false);

	    yield return new WaitForSeconds(1);
	    int totalCount = SequenceManager.unique.sequence.Gestures.Length;
	    int i = 0;
	    while (i < totalCount)
	    {
		    i += 1;
		    countVibration.Start();
		    scoreLabel.text = i.ToString();

			_scoreAnimator.SetTrigger(Change);
			if (i > SequenceManager.unique.lastHighScore)
			{
				_scoreAnimator.SetBool(HighScore, true);
			}

			yield return new WaitForSeconds(0.75f);
	    }

	    _completedCounting = true;
    }

    private void HandleTap(LeanFinger finger)
    {
	    switch (MainMenu.state)
	    {
		    case MainMenu.AppState.PostGame:
			    if (!_completedCounting) return;
			    MainMenu.state = MainMenu.AppState.Game;
			    break;
		    default:
			    break;
	    }
    }
}