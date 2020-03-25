using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ReplayMenu : MonoBehaviour
{

    public TMP_Text scoreLabel;
    
    private MainMenu.AppState _state;
    
    // Start is called before the first frame update
    void Start()
    {
        
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
                    scoreLabel.text = MainMenu.saveState.highScore.ToString();
                    break;
                default:
                    break;
            }
        }
    }
}
