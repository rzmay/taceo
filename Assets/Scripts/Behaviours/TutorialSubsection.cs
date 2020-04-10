using System.Collections;
using System.Collections.Generic;
using System.Dynamic;
using JetBrains.Annotations;
using TMPro;
using UnityEngine;

public class TutorialSubsection : MonoBehaviour
{
    
    private static readonly int TextHidden = Animator.StringToHash("hidden");

    [System.Serializable]
    public class TutorialText
    {
        public TMP_Text text;
        public float entryTime;
        
        public Util.VibrationData vibration;

        public Animator animator => _animator;
        private Animator _animator;

        public void SetAnimator()
        {
            _animator = text.gameObject.AddComponent<Animator>();
            _animator.runtimeAnimatorController = TutorialMenu.TutorialTextAnimator;
        }

        public void Present()
        {
            _animator.SetBool(TextHidden, false);

            if (vibration?.intensityCurve.keys.Length > 0) vibration?.Start();
        }

        public void Hide()
        {
            _animator.SetBool(TextHidden, true);
        }

        public IEnumerator Init(float audioDuration, float delay)
        {
            yield return new WaitForSeconds(entryTime);
            Present();
            yield return new WaitForSeconds(audioDuration + delay - entryTime);
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
            tutorialText.Hide();
        }
    }

    // Update is called once per frame
    void Update()
    {
        // pass
    }

    public void Play()
    {
        AudioSource.PlayClipAtPoint(audio, Camera.main.transform.position);
        float length = audio.length;
        
        foreach (TutorialText tutorialText in texts)
        {
            StartCoroutine(tutorialText.Init(length, delay));
        }
    }
}
