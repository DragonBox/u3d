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

describe U3dCore do
  describe U3dCore::Credentials do
    let(:user) { "felix@krausefx.com" }
    let(:password) { "suchSecret" }

    it "allows passing user and password" do
      c = U3dCore::Credentials.new(user: user, password: password)
      expect(c.user).to eq(user)
      expect(c.password).to eq(password)
    end

    it "allows setting an empty password" do
      c = U3dCore::Credentials.new(user: user, password: '')
      expect(c.password).to eq('')
    end

    it "loads the user from the new 'U3D_USER' variable" do
      ENV['U3D_USER'] = user
      c = U3dCore::Credentials.new
      expect(c.user).to eq(user)
      ENV.delete('U3D_USER')
    end

    it "loads the password from the new 'U3D_PASSWORD' variable" do
      ENV['U3D_PASSWORD'] = password
      c = U3dCore::Credentials.new
      expect(c.password).to eq(password)
      ENV.delete('U3D_PASSWORD')
    end

    it "loads an empty password from the new 'U3D_PASSWORD' variable" do
      ENV['U3D_PASSWORD'] = ''
      c = U3dCore::Credentials.new
      expect(c.password).to eq('')
      ENV.delete('U3D_PASSWORD')
    end

    it "automatically loads the password from the keychain" do
      U3dCore::Globals.with_use_keychain(true) do
        allow(U3d::Helper).to receive(:mac?) { true }

        ENV['U3D_USER'] = user
        c = U3dCore::Credentials.new

        dummy = Object.new
        expect(dummy).to receive(:password).and_return("Yeah! Pass!")

        expect(Security::InternetPassword).to receive(:find).with(server: "u3d").and_return(dummy)
        expect(c.password).to eq("Yeah! Pass!")
        ENV.delete('U3D_USER')
      end
    end

    xit "removes the Keychain item if the user agrees when the credentials are invalid" do
      expect(Security::InternetPassword).to receive(:delete).with(server: "u3d").and_return(nil)

      c = U3dCore::Credentials.new(user: "felix@krausefx.com")
      expect(c).to receive(:ask_for_login).and_return(nil)
      c.invalid_credentials(force: true)
    end

    it "defaults to 'u3d' as a prefix" do
      c = U3dCore::Credentials.new(user: user)
      expect(c.server_name).to eq("u3d")
    end

    xit "supports custom prefixes" do
      prefix = "custom-prefix"
      c = U3dCore::Credentials.new(user: user, prefix: prefix)
      expect(c.server_name).to eq("#{prefix}.#{user}")
    end
  end

  after(:each) do
    ENV.delete("U3D_USER")
  end
end
