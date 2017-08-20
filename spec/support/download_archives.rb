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
def windows_archive
  %(
    <li><a href="http://download.unity3d.com/download_unity/d3101c3b8468/Windows64EditorInstaller/UnitySetup64-1.2.3f1.exe">Éditeur 64 bits</a></li>
    <li><a href="http://download.unity3d.com/download_unity/d3101c3b8468/Windows64EditorInstaller/UnitySetup64-1.3.5f1.exe">Éditeur 64 bits</a></li>
    <li><a href="http://download.unity3d.com/download_unity/d3101c3b8468/Windows64EditorInstaller/UnitySetup64-2017.1.6f1.exe">Éditeur 64 bits</a></li>
  )
end

def macosx_archive
  %(
    <li><a href="http://download.unity3d.com/download_unity/d3101c3b8468/MacEditorInstaller/Unity-1.2.3f1.pkg">Éditeur Unity</a></li>
    <li><a href="http://download.unity3d.com/download_unity/d3101c3b8468/MacEditorInstaller/Unity-1.3.5f1.pkg">Éditeur Unity</a></li>
    <li><a href="http://download.unity3d.com/download_unity/d3101c3b8468/MacEditorInstaller/Unity-2017.1.6f1.pkg">Éditeur Unity</a></li>
  )
end

def linux_archive
  %(
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh</a><br />
  )
end

def linux_nested_archive
  %(
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.2.3f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-1.3.5f1+20160316.sh</a><br />
    <b>5.4.0b10</b>: <a href="http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh" target="_blank" class="externalLink">http://download.unity3d.com/download_unity/linux/unity-editor-installer-2017.1.6f1+20160316.sh</a><br />
    <b>2017.1.0b3</b>:<a href="http://beta.unity3d.com/download/b515b8958382/public_download.html" target="_blank" class="externalLink">
  )
end

def linux_inner_archive
  page_archive = double("Net::HTTPResponse")
  body = %(
    <html><head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head><body><h2>Unity 2017.1.0xb3Linux Linux Editor downloads</h2>
    <p>Welcome to the Linux Editor download repository.  Here, you will find the download links to experimental releases of the Linux Editor.</p>
    <h3>Debian Package</h3>
    <a href='http://beta.unity3d.com/download/b515b8958382/./unity-editor_amd64-2017.1.0xb3Linux.deb'>Linux Editor Installer (.deb package)</a><br>
    <h3>Platform-Agnostic Self-Extracting Shell Script</h3>
    <a href='http://beta.unity3d.com/download/b515b8958382/./unity-editor-installer-2017.1.0xb3Linux.sh'>Linux Editor Installer (self-extracting shell script)</a><br>
    </body></html>
  )
  allow(page_archive).to receive(:is_a?).with(Net::HTTPSuccess) { true }
  allow(page_archive).to receive(:body) { body }
  return page_archive
end
