describe Fastlane::Actions::U3dAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The u3d plugin is working!")

      Fastlane::Actions::U3dAction.run(nil)
    end
  end
end
