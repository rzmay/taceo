using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using Lean.Touch;
using UnityEngine;
using UnityEngine.UIElements;
using Random = UnityEngine.Random;

[RequireComponent(typeof(Rigidbody2D))]
public class LogoBall : MonoBehaviour
{

	// Bot influences ball position
	public static float vibrationIntensity;

	[Header("Wave")]
	public float wavePeriod;
	public float waveAmplitude;

	[Space] [Header("Attraction")]
	public float touchAttraction;
	public float vibrationInfluence;

	[Space] [Header("Particle")]
	[SerializeReference]
	public ParticleSystem hitParticle;

	[Space] [Header("Physics")]
	public Collider2D ringCollider;

	private float _phase;

	private bool _gameOver;

	private Vector2 _originalLocation;
	private MainMenu.AppState _state;

	private Rigidbody2D _rb;
	private Camera _camera;

	// Start is called before the first frame update
    void Start()
    {
	    _rb = GetComponent<Rigidbody2D>();
	    _camera = Camera.main;

	    _phase = Random.value;
	    _state = MainMenu.AppState.MainMenu;

	    _originalLocation = _rb.position;

	    vibrationIntensity = 0.0f;
    }

    private void FixedUpdate()
    {
	    // On state change
	    if (_state != MainMenu.state)
	    {
		    // Switching from PostGame
		    if (_state == MainMenu.AppState.PostGame)
		    {
			    transform.position = _originalLocation;
			    _rb.velocity = Vector2.zero;
		    }
		    _state = MainMenu.state;
	    }
	    
	    switch (MainMenu.state)
	    {
		    case MainMenu.AppState.MainMenu:
			    Wave();
			    break;
		    case MainMenu.AppState.Game:
			    MoveTowardsTouch();
			    break;
		    case MainMenu.AppState.GameOver:
			    GameOver();
			    break;
		    case MainMenu.AppState.PostGame:
			    GameOver();
			    break;
		    case MainMenu.AppState.Replay:
			    MoveTowardsTouch();
			    break;
		    default:
			    // Position static
			    _rb.bodyType = RigidbodyType2D.Static;
			    transform.position = _originalLocation;
			    break;
	    }
    }

    private void Wave()
    {
	    ringCollider.enabled = true;
	    _rb.bodyType = RigidbodyType2D.Dynamic;
	    _rb.gravityScale = 0.0f;

	    Vector2 movement = new Vector2(
		    0,
		    Mathf.Sin((Time.time + _phase) * (2f * (float) Math.PI / wavePeriod)) * waveAmplitude
		);

		_rb.MovePosition(Vector2.Lerp(_rb.position, _originalLocation, 1 * Time.fixedDeltaTime) + movement);
    }

    private void MoveTowardsTouch()
    {
	    ringCollider.enabled = true;
	    _rb.bodyType = RigidbodyType2D.Dynamic;
	    _rb.gravityScale = 1.0f;
	    
	    StayInRing();

	    // Apply attraction to all fingers
	    foreach (LeanFinger finger in LeanTouch.Fingers)
	    {
		    Vector2 fingerPos = Util.Camera.ScreenToWorldPointPerspective(
			    _camera,
			    finger.ScreenPosition,
			    transform.position.z
			);
		    Vector2 fingerDirection = (fingerPos - _rb.position);
		    _rb.AddForce(touchAttraction * Time.fixedDeltaTime * fingerDirection);
	    }

	    // Apply vibration attraction
	    _rb.AddForce(vibrationInfluence * vibrationIntensity * Time.fixedDeltaTime * Vector2.up);
    }

    private void GameOver()
    {
	    // Only call once
	    if (_gameOver) return;
	    _gameOver = true;

	    ringCollider.enabled = false;
	    _rb.velocity = new Vector2(
		    _rb.position.x,
		    5
		);
    }

    private void StayInRing()
    {
	    // If ball has left circle, return to original position
	    if (!ringCollider.bounds.Contains(_rb.position))
	    {
		    _rb.position = _originalLocation;
		    _rb.velocity = Vector2.zero;
	    }
    }

    private void OnCollisionEnter2D(Collision2D other)
    {
	    ContactPoint2D contact = other.contacts[0];
	    ParticleSystem ps = Instantiate(
		    hitParticle,
		    new Vector3(contact.point.x, contact.point.y, transform.position.z),
		    Quaternion.Euler(0, 0, Mathf.Atan2(contact.normal.y, contact.normal.x) * Mathf.Rad2Deg)
	    );
	    GameObject o = ps.gameObject;
	    o.transform.localScale *= contact.normalImpulse / 10;
	    Destroy(o, ps.main.duration);
    }
}
