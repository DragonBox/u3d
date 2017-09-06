## --- BEGIN LICENSE BLOCK ---
# Original work Copyright (c) 2015-present the fastlane authors
# Modified work Copyright 2016-present WeWantToKnow AS
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

require 'u3d_core/helper'
require 'security'

module U3dCore
  class Credentials
    MAC_U3D_SERVER = 'u3d'.freeze
    def initialize(user: nil, password: nil)
      @user = user
      @password = password
      @use_keychain = U3dCore::Globals.use_keychain?
    end

    def user
      @user ||= ENV['U3D_USER']

      while @user.to_s.empty?
        UI.verbose 'Username does not exist or is empty'
        raise CredentialsError, 'Username missing and context is not interactive. Please check that the environment variable is correct' unless UI.interactive?
        @user = UI.input 'Username for u3d:'
      end

      return @user
    end

    def password
      @password ||= ENV['U3D_PASSWORD']

      if Helper.mac? && @use_keychain
        unless @password
          UI.message 'Fetching password from keychain'
          password_holder = Security::InternetPassword.find(server: server_name)
          @password = password_holder.password unless password_holder.nil?
        end
      end

      if @password.nil?
        UI.verbose 'Could not retrieve password'
        if U3dCore::Globals.do_not_login?
          UI.verbose 'Login disabled'
        else
          login
        end
      end

      return @password
    end

    def login
      UI.verbose 'Attempting to login'

      raise CredentialsError, 'No username specified' unless user

      while @password.nil?
        UI.verbose 'Password does not exist'
        raise CredentialsError, 'Password missing and context is not interactive. Please make sure it is correct' unless UI.interactive?
        @password = UI.password "Password for #{user}:"
      end

      if remember_credentials
        UI.success 'Credentials have been stored'
      else
        UI.important 'No credentials storage available'
      end
    end

    def remember_credentials
      ENV['U3D_USER'] = @user
      ENV['U3D_PASSWORD'] = @password
      if Helper.mac? && @use_keychain
        UI.message 'Storing credentials to the keychain'
        return Security::InternetPassword.add(server_name, user, password)
      end

      return false
    end

    def forget_credentials(force: false)
      @password = nil
      ENV['U3D_PASSWORD'] = nil
      if force || UI.interactive?
        if Helper.mac? && @use_keychain && (force || UI.confirm('Remove credentials from the keychain?'))
          UI.message 'Deleting credentials from the keychain'
          Security::InternetPassword.delete(server: server_name)
        end
      elsif Helper.mac?
        UI.verbose 'Keychain may store invalid credentials for u3d'
      end
    end

    def server_name
      MAC_U3D_SERVER
    end
  end

  class CredentialsError < StandardError
  end
end
