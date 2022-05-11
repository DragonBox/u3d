# frozen_string_literal: true

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

require 'u3d_core/core_ext/string'
require 'u3d_core/globals'
require 'u3d_core/helper'
require 'u3d_core/credentials'
require 'u3d_core/ui/ui'
require 'u3d_core/command_executor'
require 'u3d_core/command_runner'
require 'u3d_core/env'
require 'u3d_core/update_checker/changelog'
require 'u3d_core/update_checker/update_checker'
require 'colored'
require 'commander'
