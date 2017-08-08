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
  # all these attributes are false by default
  # and can be set overriden temporarily using a
  #   with_attr(value) do
  #     something
  #   end
  # construct
  class Globals
    class << self
      attr_writer :verbose, :log_timestamps, :use_keychain, :do_not_login

      def attributes
        @attributes ||= ((methods - public_instance_methods).grep(/=$/) - [:<=, :>=]).map do |s|
          a = s.to_s
          a[0..(a.length - 2)] # remove the '='
        end
      end

      def with(attr, value)
        orig_attr = send("#{attr}?")
        send("#{attr}=", value)
        yield if block_given?
      ensure
        send("#{attr}=", orig_attr)
      end

      def is?(attr)
        instance_variable_get("@#{attr}")
      end

      def method_missing(method_sym, *arguments, &block)
        if method_sym.to_s =~ /^with_(.*)$/
          if attributes.include? Regexp.last_match(1)
            with(Regexp.last_match(1).to_sym, arguments.first, &block)
          else
            super
          end
        elsif method_sym.to_s =~ /^(.*)\?$/
          if attributes.include? Regexp.last_match(1)
            is?(Regexp.last_match(1).to_sym)
          else
            super
          end
        else
          super
        end
      end

      def respond_to_missing?(method_sym, include_private = false)
        if method_sym.to_s =~ /^with_(.*)$/
          return attributes.include? Regexp.last_match(1)
        elsif method_sym.to_s =~ /^(.*)\?$/
          return attributes.include? Regexp.last_match(1)
        else
          super
        end
      end
    end
    private_class_method :is?, :with, :attributes
  end
end
