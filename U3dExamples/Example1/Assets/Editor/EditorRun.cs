using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

namespace U3d {
  class EditorRun {
    [MenuItem ("U3d/Example/LoadSaveScenes")]
    static void LoadSaveScenes() {
      if(EditorApplication.isPlaying) {
        Debug.LogError("Do not run while playing");
        return;
      }
      IEnumerable<string> scenes = FileSystemUtil.GetFiles("Assets/");
      foreach(string path in scenes) {
        if (path.EndsWith(".unity")) {
          Debug.Log("Loading " + path);
          EditorApplication.OpenScene(path);
          EditorApplication.SaveScene(path);
        }
      }
    }
  }
}