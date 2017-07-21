using UnityEngine;
using UnityEditor;
using System.Collections;

namespace WWTK {
	[InitializeOnLoad]
	public class SimpleBuildSetup {

		static SimpleBuildSetup()
		{
			Run();
		}

		public static void Run () {
			Debug.Log("Forcing SerializationMode.ForceText and Visible Meta Files");
			EditorSettings.externalVersionControl = "Visible Meta Files";
			EditorSettings.serializationMode = SerializationMode.ForceText;
		}
	}
}