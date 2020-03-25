using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

[RequireComponent(typeof(TMP_Text))]
public class TextSizeSource : MonoBehaviour
{

    public TMP_Text source;
    public float multiplier = 1f;

    private TMP_Text _text;
    
    // Start is called before the first frame update
    void Start()
    {
        _text = GetComponent<TMP_Text>();

        _text.enableAutoSizing = false;
        _text.fontSize = source.fontSize * multiplier;
    }

}
