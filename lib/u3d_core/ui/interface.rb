# frozen_string_literal: true

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

module U3dCore
  # Abstract super class
  class Interface
    #####################################################
    # @!group Messaging: show text to the user
    #####################################################

    # Level Error: Can be used to show additional error
    #   information before actually raising an exception
    #   or can be used to just show an error from which
    #   u3d can recover (much magic)
    #
    #   By default those messages are shown in red
    def error(_message)
      not_implemented(__method__)
    end

    # Level Important: Can be used to show warnings to the user
    #   not necessarly negative, but something the user should
    #   be aware of.
    #
    #   By default those messages are shown in yellow
    def important(_message)
      not_implemented(__method__)
    end

    # Level Success: Show that something was successful
    #
    #   By default those messages are shown in green
    def success(_message)
      not_implemented(__method__)
    end

    # Level Message: Show a neutral message to the user
    #
    #   By default those messages shown in white/black
    def message(_message)
      not_implemented(__method__)
    end

    # Level Deprecated: Show that a particular function is deprecated
    #
    #   By default those messages shown in strong blue
    def deprecated(_message)
      not_implemented(__method__)
    end

    # Level Command: Print out a terminal command that is being
    #   executed.
    #
    #   By default those messages shown in cyan
    def command(_message)
      not_implemented(__method__)
    end

    # Level Command Output: Print the output of a command with
    #   this method
    #
    #   By default those messages shown in magenta
    def command_output(_message)
      not_implemented(__method__)
    end

    # Level Verbose: Print out additional information for the
    #   users that are interested. Will only be printed when
    #   $verbose = true
    #
    #   By default those messages are shown in white
    def verbose(_message)
      not_implemented(__method__)
    end

    # Print a header = a text in a box
    #   use this if this message is really important
    def header(_message)
      not_implemented(__method__)
    end

    #####################################################
    # @!group Errors: Inputs
    #####################################################

    # Is is possible to ask the user questions?
    def interactive?(_message)
      not_implemented(__method__)
    end

    # get a standard text input (single line)
    def input(_message)
      not_implemented(__method__)
    end

    # A simple yes or no question
    def confirm(_message)
      not_implemented(__method__)
    end

    # Let the user select one out of x items
    # return value is the value of the option the user chose
    def select(_message, _options)
      not_implemented(__method__)
    end

    # Password input for the user, text field shouldn't show
    # plain text
    def password(_message)
      not_implemented(__method__)
    end

    #####################################################
    # @!group Errors: Different kinds of exceptions
    #####################################################

    # raised from crash!
    class UICrash < StandardError
    end

    # raised from user_error!
    class UIError < StandardError
      attr_reader :show_github_issues

      def initialize(show_github_issues: false)
        @show_github_issues = show_github_issues
      end
    end

    # Pass an exception to this method to exit the program
    #   using the given exception
    # Use this method instead of user_error! if this error is
    # unexpected, e.g. an invalid server response that shouldn't happen
    def crash!(exception)
      raise UICrash.new, exception.to_s
    end

    # Use this method to exit the program because of an user error
    #   e.g. app doesn't exist on the given Developer Account
    #        or invalid user credentials
    #        or scan tests fail
    # This will show the error message, but doesn't show the full
    #   stack trace
    # Basically this should be used when you actively catch the error
    # and want to show a nice error message to the user
    def user_error!(error_message, options = {})
      options = { show_github_issues: false }.merge(options)
      raise UIError.new(show_github_issues: options[:show_github_issues]), error_message.to_s
    end

    #####################################################
    # @!group Helpers
    #####################################################
    def not_implemented(method_name)
      UI.user_error!("Current UI '#{self}' doesn't support method '#{method_name}'")
    end

    def to_s
      self.class.name.split('::').last
    end
  end
end
