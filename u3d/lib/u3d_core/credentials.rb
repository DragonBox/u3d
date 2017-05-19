require 'u3d_core/helper'
require 'security'

module U3dCore
  class Credentials
    MAC_U3D_SERVER = 'u3d'
    def initialize(user: nil, password: nil)
      @user = user
      @password = password
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

      if Helper.mac?
        unless @password
          UI.verbose 'Fetching password from keychain'
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
      if Helper.mac?
        UI.verbose 'Storing credentials to the keychain'
        return Security::InternetPassword.add(MAC_U3D_SERVER, user, password)
      end

      return false
    end

    def forget_credentials
      @password = nil
      ENV['U3D_PASSWORD'] = nil
      if Helper.mac?
        UI.verbose 'Deleting credentials from the keychain'
        Security::InternetPassword.delete(server: MAC_U3D_SERVER)
      end
    end
  end

  class CredentialsError < StandardError
  end
end
