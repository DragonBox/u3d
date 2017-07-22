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
  class UI
    class << self
      def current
        @current ||= Shell.new
      end
    end

    def self.method_missing(method_sym, *args, &_block)
      # not using `responds` beacuse we don't care about methods like .to_s and so on
      interface_methods = Interface.instance_methods - Object.instance_methods
      UI.user_error!("Unknown method '#{method_sym}', supported #{interface_methods}") unless interface_methods.include?(method_sym)

      current.send(method_sym, *args)
    end
  end
end

require 'u3d_core/ui/interface'

# Import all available implementations
Dir[File.expand_path('implementations/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
