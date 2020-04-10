using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialMenu : MonoBehaviour
{

    public List<TutorialSection> sections = new List<TutorialSection>();
    public RuntimeAnimatorController tutorialTextAnimator;

    [Space] public float delay;

    private MainMenu.AppState _state;

    private static TutorialMenu _unique;
    public static RuntimeAnimatorController TutorialTextAnimator => _unique.tutorialTextAnimator;

    // Start is called before the first frame update
    void Start()
    {
        _state = MainMenu.AppState.MainMenu;
        _unique = this;
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
                case MainMenu.AppState.Tutorial:
                    StartCoroutine(Play());
                    break;
                default:
                    // pass
                    break;
            }
        }
    }
    
    public IEnumerator Play()
    {
        yield return new WaitForSeconds(delay);
        yield return StartCoroutine(PlaySection(0));

        // Save & return to main menu
        MainMenu.saveState.hasSeenTutorial = true;
        SaveSystem.SaveData(MainMenu.saveState);
        
        MainMenu.state = MainMenu.AppState.MainMenu;
    }

    private IEnumerator PlaySection(int index)
    {
        if (index < sections.Count)
        {
            sections[index].gameObject.SetActive(true);
            
            yield return sections[index].Play();
            
            sections[index].gameObject.SetActive(false);
            
            yield return PlaySection(index + 1);
        }
    }
}
