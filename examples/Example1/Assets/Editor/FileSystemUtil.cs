using System.IO;
using System.Collections.Generic;

public static class FileSystemUtil
{	
	public static IEnumerable<string> GetFiles(string path) {
		Queue<string> queue = new Queue<string>();
		queue.Enqueue(path);
		while (queue.Count > 0) {
			path = queue.Dequeue();
			if (!Directory.Exists(path)) continue;
			foreach (string subDir in Directory.GetDirectories(path)) {
				queue.Enqueue(subDir);
			}
			string[] files = null;
			files = Directory.GetFiles(path);
			if (files != null) {
				for(int i = 0 ; i < files.Length ; i++) {
					yield return files[i];
				}
			}
		}
	}
}


