using UnityEngine;
using UnityEngine.SocialPlatforms.GameCenter;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class NewBehaviourScript : MonoBehaviour {

	private bool first = true;
	public Text text;

	void Update ()
	{
		if(first)
		{
			first = false;

			GameCenterPlatform.ShowDefaultAchievementCompletionBanner(true);
			Social.localUser.Authenticate( result =>
				{
					text.text = "Logged in: " + result;
					
					if(result)
					{
						_GameCenterSetup();
					}
				}
			);
		}
	}

	public void doTheKeysThing()
	{
		foreach( string key in new List<string>{"app_bundle_id", "player_id", "signature", "public_key_url", "salt", "timestamp"} )
		{
			string val = _GameCenterGetKey(key);
			if( !string.IsNullOrEmpty(val) )
			{
				text.text = string.Format("{0}: {1}\n", key, val) + text.text;
			}
		}
	}
	
	[DllImport("__Internal")]
	private static extern bool _GameCenterSetup();
	
	[DllImport("__Internal")]
	private static extern string _GameCenterGetKey(string key);
}
