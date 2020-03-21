using System.Collections;
using System.Collections.Generic;
using UnityEditor.SceneManagement;
using UnityEngine;

public class SaveState
{
	public int highScore;
	public SequenceManager.Sequence sequence;

	public SaveState()
	{
		highScore = 0;
		sequence = new SequenceManager.Sequence();
	}

	public SaveState(int highScore, SequenceManager.Sequence sequence)
	{
		this.highScore = highScore;
		this.sequence = sequence;
	}
}
