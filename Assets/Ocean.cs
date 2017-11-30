using UnityEngine;
using System.Collections;

public class Ocean : MonoBehaviour 
{
    private Material mMateiral;

	// Use this for initialization
	void Start () 
    {
        Application.targetFrameRate = 30;

        MeshRenderer meshrenderer = GetComponent<MeshRenderer>();
        mMateiral = meshrenderer.material;
	}
	
    void FixedUpdate()
    {
        mMateiral.SetFloat("u_time", Time.time);
    }
}
