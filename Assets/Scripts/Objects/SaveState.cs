using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class SaveState
{
	public bool hasSeenTutorial;
	
	public int highScore;
	public SequenceManager.Sequence sequence;

	public SaveState()
	{
		highScore = 0;
		sequence = new SequenceManager.Sequence();
		
		hasSeenTutorial = false;
	}

	public SaveState(int highScore, SequenceManager.Sequence sequence, bool hasSeenTutorial = false)
	{
		this.highScore = highScore;
		this.sequence = sequence;

		this.hasSeenTutorial = hasSeenTutorial;
	}
}
