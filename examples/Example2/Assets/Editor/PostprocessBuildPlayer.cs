using UnityEngine;
using System.Collections;
using UnityEditor;
using UnityEditor.Callbacks;
using System.IO;
using System;
using System.Text;

public class PostprocessBuildPlayer : ScriptableObject {

  [PostProcessBuild]
  static void OnPostprocessBuildPlayer(BuildTarget target, string buildPath) {
    if (Application.platform == RuntimePlatform.WindowsEditor) {
      Debug.LogWarning("PostprocessBuildPlayer not supported on Windows");
      return;
    }

    string editorPath = Path.GetFullPath(Path.GetDirectoryName(AssetDatabase.GetAssetPath(MonoScript.FromScriptableObject(ScriptableObject.CreateInstance<PostprocessBuildPlayer>()))));

    if (!Directory.Exists(editorPath)) {
      Debug.LogError("No directory at: " + editorPath);
      return;
    }

    if (!Directory.Exists(buildPath) && !File.Exists(buildPath)) {
      Debug.LogError("No directory at: " + buildPath);
      return;
    }

    var files = Directory.GetFiles(editorPath, "*.*", SearchOption.TopDirectoryOnly);

    files = System.Array.FindAll<string>(files, (x) => {
      var name = Path.GetFileName(x).ToLower();

      return name.StartsWith("postprocessbuildplayer_") && !name.EndsWith("meta");
    });

    if (files.Length == 0) {
      Debug.Log("No postprocess scripts at: " + editorPath);
      return;
    }

    var args = new string[] {
      buildPath,
      target.ToString()
    };

    foreach (var file in files) {
      string AllArgs = string.Join(" ", args);
      Debug.Log("executing: " + file + " " + AllArgs);

      using (var process = new System.Diagnostics.Process()) {
        process.StartInfo.FileName = file;
        process.StartInfo.Arguments = AllArgs;
        process.StartInfo.RedirectStandardError = true;
        process.StartInfo.RedirectStandardOutput = true;
        process.StartInfo.UseShellExecute = false;

        StringBuilder stdout = new StringBuilder();
        StringBuilder stderr = new StringBuilder();

        process.OutputDataReceived += (sender, e) => {
          if (e.Data == null) return;
          stdout.Append(e.Data).Append("\n");
        };
        process.ErrorDataReceived += (sender, e) => {
          if (e.Data == null) return;
          stderr.Append(e.Data).Append("\n");
        };
        process.EnableRaisingEvents = true;

        process.Start();

        process.BeginOutputReadLine();
        process.BeginErrorReadLine();

        process.WaitForExit();

        string output = stdout.ToString();
        if (output.Length > 0)
          Debug.Log("** output: \n" + output);
        string error = stderr.ToString();
        if (error.Length > 0)
          Debug.Log("** error: \n" + error);

        if (process.ExitCode != 0) {
          throw new Exception("Failer running " + file + " error: " + process.ExitCode + " : " + error);
        }
      }
    }
  }
}
