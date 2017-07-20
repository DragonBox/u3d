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
    MAC_U3D_SERVER = 'u3d'
    def initialize(user: nil, password: nil)
      @user = user
      @password = password
      @use_keychain = U3dCore::Globals.use_keychain?
    end

    def user
      @user ||= ENV['U3D_USER']

      while @user.to_s.empty?
        UI.verbose 'Username does not exist or is empty'
        if UI.interactive?
          @user = UI.input 'Username for u3d:'
        else
          raise CredentialsError, 'Username missing and context is not interactive. Please check that the environment variable is correct'
        end
      end

      return @user
    end

    def password
      @password ||= ENV['U3D_PASSWORD']

      if Helper.mac? && @use_keychain
        unless @password
          UI.message 'Fetching password from keychain'
          password_holder = Security::InternetPassword.find(server: MAC_U3D_SERVER)
          @password = password_holder.password unless password_holder.nil?
        end
      end

      if @password.to_s.empty?
        UI.verbose 'Could not retrieve password'
        login
      end

      return @password
    end

    def login
      UI.verbose 'Attempting to login'

      raise CredentialsError, 'No username specified' unless user

      while @password.to_s.empty?
        UI.verbose 'Password does not exist or is empty'
        if UI.interactive?
          @password = UI.password "Password for #{user}:"
        else
          raise CredentialsError, 'Password missing and context is not interactive. Please make sure it is correct'
        end
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
        return Security::InternetPassword.add(MAC_U3D_SERVER, user, password)
      end

      return false
    end

    def forget_credentials(force: false)
      @password = nil
      ENV['U3D_PASSWORD'] = nil
      if force || UI.interactive?
        if Helper.mac? && @use_keychain && (force || UI.confirm('Remove credentials from the keychain?'))
          UI.message 'Deleting credentials from the keychain'
          Security::InternetPassword.delete(server: MAC_U3D_SERVER)
        end
      else
        UI.verbose 'Keychain may store invalid credentials for u3d' if Helper.mac?
      end
    end
  end

  class CredentialsError < StandardError
  end
end
