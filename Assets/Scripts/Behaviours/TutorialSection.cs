using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialSection : MonoBehaviour
{
    
    public List<TutorialSubsection> subsections = new List<TutorialSubsection>();

    public float padding;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void Play()
    {
        StartCoroutine(PlaySubsection(0));
    }

    private IEnumerator PlaySubsection(int index)
    {
        if (index < subsections.Count)
        {
            subsections[index].Play();
            yield return new WaitForSeconds(subsections[index].audio.length + padding);
            StartCoroutine(PlaySubsection(index + 1));
        }
    }
}
