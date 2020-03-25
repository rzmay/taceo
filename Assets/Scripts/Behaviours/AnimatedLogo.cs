using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatedLogo : MonoBehaviour
{

	public enum LogoState
	{
		Default,
		Inverted,
		Focus
	}

	public GameObject innerRing;
	public GameObject outerRing;

	public GameObject ringCollider;

	public LogoState state;

	private Animator _innerRingAnimator;
	private Animator _outerRingAnimator;
	private Animator _ringColliderAnimator;
	private static readonly int Focus = Animator.StringToHash("Focus");

	// Start is called before the first frame update
    void Start()
    {
	    _innerRingAnimator = innerRing.GetComponent<Animator>();
	    _outerRingAnimator = outerRing.GetComponent<Animator>();
	    _ringColliderAnimator = ringCollider.GetComponent<Animator>();

	    SetState(LogoState.Default);
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void SetState(LogoState state)
    {
	    this.state = state;
	    switch (state)
	    {
		    case LogoState.Default:
			    _innerRingAnimator.SetInteger(Focus, 1);
			    _ringColliderAnimator.SetInteger(Focus, 1);
			    
			    _outerRingAnimator.SetInteger(Focus, 0);
			    break;
		    case LogoState.Inverted:
			    _innerRingAnimator.SetInteger(Focus, 0);

			    _outerRingAnimator.SetInteger(Focus, 1);
			    _ringColliderAnimator.SetInteger(Focus, 1);
			    break;
			case LogoState.Focus:
			    _innerRingAnimator.SetInteger(Focus, 2);
			    _ringColliderAnimator.SetInteger(Focus, 2);
			    
			    _outerRingAnimator.SetInteger(Focus, 0);
			    break;
	    }
    }
}
