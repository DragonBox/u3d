## --- BEGIN LICENSE BLOCK ---
# Copyright (c) 2016-present WeWantToKnow AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
## --- END LICENSE BLOCK ---

# Various fake download archives
def macosx_windows_archive
  %(
    <li><a href="https://download.unity3d.com/download_unity/builtin_shaders-4.7.2.zip">Shaders</a></li>
    <li><a href="https://download.unity3d.com/download_unity/builtin_shaders-4.7.2.zip">Shaders</a></li>
    <li><a href="https://download.unity3d.com/download_unity/6bac21139588/builtin_shaders-5.6.6f2.zip">Shaders</a></li>
    <li><a href="https://download.unity3d.com/download_unity/6bac21139588/builtin_shaders-5.6.6f2.zip">Shaders</a></li>
    <li><a href="https://netstorage.unity3d.com/unity/9e14d22a41bb/builtin_shaders-2018.3.7f1.zip"></a></li>
    <li><a href="https://netstorage.unity3d.com/unity/9e14d22a41bb/builtin_shaders-2018.3.7f1.zip"></a></li>
  )
end

def latest_windows_archive
  %(
{
  "official": [
    {
      "version": "2017.1.5f1",
      "lts": false,
      "downloadUrl": "https://download.unity3d.com/download_unity/9758a36cfaa6/Windows64EditorInstaller/UnitySetup64-2017.1.5f1.exe",
      "downloadSize": 534723584,
      "installedSize": 1779680256,
      "checksum": "8937731134e0109620af32f6f52ce1c6",
      "modules": []
    }
  ],
  "beta": [
    {
      "version": "2018.3.0b12",
      "lts": false,
      "downloadUrl": "https://beta.unity3d.com/download/77f6238a7ced/Windows64EditorInstaller/UnitySetup64-2018.3.0b12.exe",
      "downloadSize": 583775232,
      "installedSize": 2028078080,
      "checksum": "4238474477c552cce34072c8061c5dcd",
      "modules": []
    }
  ]
}
  )
end

def latest_macosx_archive
  %(
{
  "official": [
    {
      "version": "2017.1.5f1",
      "lts": false,
      "downloadUrl": "https://download.unity3d.com/download_unity/9758a36cfaa6/MacEditorInstaller/Unity-2017.1.5f1.pkg",
      "downloadSize": 886532131,
      "installedSize": 2365775000,
      "checksum": "1de0b7d9f705dbd0eab65cbf2cc693ee",
      "modules": []
    }
  ],
  "beta": [
    {
      "version": "2018.3.0b12",
      "lts": false,
      "downloadUrl": "https://beta.unity3d.com/download/77f6238a7ced/MacEditorInstaller/Unity-2018.3.0b12.pkg",
      "downloadSize": 1059403789,
      "installedSize": 2683800000,
      "checksum": "5a171c942fdcba9a6eb45d8ad1400778",
      "modules": []
    }
  ]
}
  )
end

def linux_archive_old
  %(
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh</a><br />
  )
end

def linux_archive_all
  %(
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh</a><br />
    <b>2017.1.0b3</b>:<a href="http://beta.unity3d.com/download/b515b8958382/public_download.html" target="_blank" class="externalLink">
    <b>2017.3.0f1</b>:<a href="http://beta.unity3d.com/download/3c89f8d277f5/public_download.html" target="_blank" class="externalLink">
    <b>2017.2.1f1</b>:<a href="https://beta.unity3d.com/download/ce9f6a0436e1+/public_download.html" target="_blank" class="externalLink">
    <b>2018.3.0f2</b>:<a href='https://beta.unity3d.com/download/6e9a27477296/UnitySetup-2018.3.0f2' target="_blank" class="externalLink">
  )
end

def linux_public_archive_standalone
  %(
    <html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head><body><h2>Unity 2017.1.0xb3Linux Linux Editor downloads</h2>
    <p>Welcome to the Linux Editor download repository.  Here, you will find the download links to experimental releases of the Linux Editor.</p>
    <h3>Debian Package</h3>
    <a href='http://beta.unity3d.com/download/b515b8958382/./unity-editor_amd64-2017.1.0xb3Linux.deb'>Linux Editor Installer (.deb package)</a><br>
    <h3>Platform-Agnostic Self-Extracting Shell Script</h3>
    <a href='http://beta.unity3d.com/download/b515b8958382/./unity-editor-installer-2017.1.0xb3Linux.sh'>Linux Editor Installer (self-extracting shell script)</a><br>
    </body></html>
  )
end

def linux_public_archive_standalone_plus
  %(
    <html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head><body><h2>Unity 2017.2.1f1 Linux Editor downloads</h2>
    <p>Welcome to the Linux Editor download repository.  Here, you will find the download links to experimental releases of the Linux Editor.</p>
    <h3>Debian Package</h3>
    <a href='https://beta.unity3d.com/download/ce9f6a0436e1+/./unity-editor_amd64-2017.2.1f1.deb'>Linux Editor Installer (.deb package)</a><br>
    <h3>Platform-Agnostic Self-Extracting Shell Script</h3>
    <a href='https://beta.unity3d.com/download/ce9f6a0436e1+/./unity-editor-installer-2017.2.1f1.sh'>Linux Editor Installer (self-extracting shell script)</a><br>
    </body></html>
  )
end

def linux_public_archive_standalone_plus_2
  %(
    <html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head><body><h2>Unity 2017.3.0p2 Linux Editor downloads</h2>
    <p>Welcome to the Linux Editor download repository.  Here, you will find the download links to experimental releases of the Linux Editor.</p>
    <h3>Unity Editor</h3>
    <a href='http://beta.unity3d.com/download/7807bc63c3ab/./UnitySetup-2017.3.0p2'>Linux Download Assistant</a><br>
    <h3>Additional Resources</h3>
    This version of Unity Remote is for Android.<br>
    <a href='http://beta.unity3d.com/download/7807bc63c3ab/./UnityRemote-Android-2017.3.0p2.apk'>Unity Android Remote</a><br>
    This version of Unity Remote is for iOS.<br>
    <a href='http://beta.unity3d.com/download/7807bc63c3ab/./UnityRemote-iOS-2017.3.0p2.zip'>Unity iOS Remote</a><br>
    Cache Server for Unity.<br>
    <a href='http://beta.unity3d.com/download/7807bc63c3ab/./CacheServer-2017.3.0p2.zip'>Unity Cache Server</a><br>
    </body></html>
  )
end

def linux_public_archive_assistant
  %(
    <html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head><body><h2>Unity 2017.3.0f1 Linux Editor downloads</h2>
    <p>Welcome to the Linux Editor download repository.  Here, you will find the download links to experimental releases of the Linux Editor.</p>
    <h3>Unity Editor</h3>
    <a href='http://beta.unity3d.com/download/3c89f8d277f5/./UnitySetup-2017.3.0f1'>Linux Download Assistant</a><br>
    <h3>Additional Resources</h3>
    This version of Unity Remote is for Android.<br>
    <a href='http://beta.unity3d.com/download/3c89f8d277f5/./UnityRemote-Android-2017.3.0f1.apk'>Unity Android Remote</a><br>
    This version of Unity Remote is for iOS.<br>
    <a href='http://beta.unity3d.com/download/3c89f8d277f5/./UnityRemote-iOS-2017.3.0f1.zip'>Unity iOS Remote</a><br>
    Cache Server for Unity.<br>
    <a href='http://beta.unity3d.com/download/3c89f8d277f5/./CacheServer-2017.3.0f1.zip'>Unity Cache Server</a><br>
    </body></html>
  )
end
