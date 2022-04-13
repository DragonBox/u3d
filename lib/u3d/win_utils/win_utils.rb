require 'fiddle/import'
require 'fiddle/types'

module Win32FiddleDirectories
  extend Fiddle::Importer
  include Fiddle::Win32Types # adds HWND, HANDLE, DWORD type aliases
  
  # calling this appears to hose everything up!
  # dlload "shell32", "kernel32"

  typealias 'LPWSTR', 'wchar_t*'
  typealias 'LONG', 'long'
  typealias 'HRESULT','LONG'

  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx
  # HRESULT SHGetFolderPath(
  #   _In_  HWND   hwndOwner,
  #   _In_  int    nFolder,
  #   _In_  HANDLE hToken,
  #   _In_  DWORD  dwFlags,
  #   _Out_ LPTSTR pszPath
  # );
  extern 'HRESULT SHGetFolderPath(HWND, int, HANDLE, DWORD, LPWSTR)'

  CSIDL_LOCAL_APPDATA = 0x001c

  def self.get_CSIDL_LOCAL_APPDATA
    buffer = 0.chr * 261 # 1024?
    SHGetFolderPath(0, CSIDL_LOCAL_APPDATA, 0, 0, buffer)
    buffer.strip
  end
end