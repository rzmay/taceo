using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialSection : MonoBehaviour
{
    
    public List<TutorialSubsection> subsections = new List<TutorialSubsection>();

    public float padding;

    public IEnumerator Play()
    {
        yield return StartCoroutine(PlaySubsection(0));
    }

    private IEnumerator PlaySubsection(int index)
    {
        if (index < subsections.Count)
        {
            subsections[index].Play();
            yield return new WaitForSeconds(subsections[index].audio.length + subsections[index].delay + padding);
            yield return PlaySubsection(index + 1);
        }
    }
}
