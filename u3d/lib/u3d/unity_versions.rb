require 'u3d/iniparser'

module U3d
  # Takes care of fectching versions and version list
  module UnityVersions
    #####################################################
    # @!group URLS: Locations to fetch information from
    #####################################################
    # URL for the main releases
    UNITY_DOWNLOADS = 'https://unity3d.com/get-unity/download/archive'.freeze
    # URL for the patch releases
    UNITY_PATCHES = 'https://unity3d.com/unity/qa/patch-releases'.freeze
    # URL for the beta releases list, they need to be accessed after
    UNITY_BETAS = 'https://unity3d.com/unity/beta/archive'.freeze
    # URL for a specific beta, takes into parameter a version string (%s)
    UNITY_BETA_URL = 'https://unity3d.com/unity/beta/unity%s'.freeze

    #####################################################
    # @!group REGEX: expressions to interpret data
    #####################################################
    # Captures a version and its base url
    UNITY_DOWNLOADS_REGEX = %r{"(https?:\/\/[\w\/.-]+\/[0-9a-f]{12}\/)MacEditorInstaller\/[\w\/.-]+(\d+\.\d+\.\d+\w\d+)[\w\/.-]+"}
    # Captures a beta version in html page
    UNITY_BETAVERSION_REGEX = %r{\/unity\/beta\/unity(\d+\.\d+\.\d+\w\d+)"}
    UNITY_EXTRA_DOWNLOAD_REGEX = %r{"(https?:\/\/[\w\/.-]+\.unity3d\.com\/(\w+))\/[\w\/.-]+\/download.html"}

    class << self
      def list_available()
        versions = {}
        UI.message 'Loading Unity releases'
        current = fetch_version(UNITY_DOWNLOADS, UNITY_DOWNLOADS_REGEX)
        UI.success "Found #{current.count} releases." if current.count != 0
        versions = versions.merge(current)
        UI.message 'Loading Unity patch releases'
        current = fetch_version(UNITY_PATCHES, UNITY_DOWNLOADS_REGEX)
        UI.success "Found #{current.count} patch releases." if current.count != 0
        versions = versions.merge(current)
        UI.message 'Loading Unity beta releases'
        current = fetch_betas(UNITY_BETAS, UNITY_DOWNLOADS_REGEX)
        UI.success "Found #{current.count} beta releases." if current.count != 0
        versions = versions.merge(current)
        versions
      end

      private #-----------------------------------------------------------------

      def fetch_version(url, pattern)
        hash = {}
        data = Utils.get_ssl(url)
        results = data.scan(pattern)
        results.each do |capt|
          UI.verbose "#{capt[1]} (#{capt[0]})"
          hash[capt[1]] = capt[0]
        end
        hash
      end

      def fetch_betas(url, pattern)
        hash = {}
        data = Utils.get_ssl(url)
        results = data.scan(UNITY_BETAVERSION_REGEX).uniq
        results.each do |beta|
          v_url = UNITY_BETA_URL % beta[0]
          hash = hash.merge(fetch_version(v_url, pattern))
        end
        hash
      end
    end
  end
end
