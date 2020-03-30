using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using JetBrains.Annotations;
using TMPro;
using UnityEngine;
using Util;

public class TutorialSubsection : MonoBehaviour
{
    
    private static readonly int TextIn = Animator.StringToHash("In");
    private static readonly int TextOut = Animator.StringToHash("Out");

    [System.Serializable]
    public class TutorialText
    {
        public TMP_Text text;
        public float entryTime;

        [CanBeNull] 
        public VibrationData vibration;

        public Animator animator => _animator;
        private Animator _animator;

        public void SetAnimator()
        {
            _animator = text.GetComponent<Animator>();
        }

        public void Present()
        {
            _animator.SetTrigger(TextIn);
            
            vibration?.Start();
        }

        public void Hide()
        {
            _animator.SetTrigger(TextOut);
        }

        public IEnumerator Init(float audioDuration, float delay)
        {
            yield return new WaitForSeconds(entryTime);
            Present();
            yield return new WaitForSeconds(audioDuration - entryTime + delay);
            Hide();
        }
    }

    [SerializeField] 
    public List<TutorialText> texts = new List<TutorialText>();
    
    public AudioClip audio;
    public float delay;

    // Start is called before the first frame update
    void Start()
    {
        foreach (TutorialText tutorialText in texts)
        {
            tutorialText.SetAnimator();
        }
    }

    // Update is called once per frame
    void Update()
    {
        // pass
    }

    public void Play()
    {
        AudioSource.PlayClipAtPoint(audio, Vector3.zero);

        foreach (TutorialText tutorialText in texts)
        {
            tutorialText.Init(audio.length, delay);
        }
    }
}
