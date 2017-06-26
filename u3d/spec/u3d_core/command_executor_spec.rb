describe U3dCore do
  describe U3dCore::CommandExecutor do
    describe "which" do
      require 'tempfile'

      it "does not find commands which are not on the PATH" do
        expect(U3dCore::CommandExecutor.which('not_a_real_command')).to be_nil
      end

      it "finds commands without extensions which are on the PATH" do
        Tempfile.create('foobarbaz') do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f)

          with_env_values('PATH' => temp_dir) do
            expect(U3dCore::CommandExecutor.which(temp_cmd)).to eq(f.path)
          end
        end
      end

      it "finds commands with known extensions which are on the PATH" do
        Tempfile.create(['foobarbaz', '.exe']) do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f, '.exe')

          with_env_values('PATH' => temp_dir, 'PATHEXT' => '.exe') do
            expect(U3dCore::CommandExecutor.which(temp_cmd)).to eq(f.path)
          end
        end
      end

      it "does not find commands with unknown extensions which are on the PATH" do
        Tempfile.create(['foobarbaz', '.exe']) do |f|
          File.chmod(0777, f)

          temp_dir = File.dirname(f)
          temp_cmd = File.basename(f, '.exe')

          with_env_values('PATH' => temp_dir, 'PATHEXT' => '') do
            expect(U3dCore::CommandExecutor.which(temp_cmd)).to be_nil
          end
        end
      end
    end
    describe "execute" do
      it "raise error upon exit status failure" do
        expect do
          output = U3dCore::CommandExecutor.execute(command: "ruby -e 'exit 1'")
        end.to raise_error(RuntimeError, /Exit status: 1/)
      end

      it "captures error output upon exit status failure" do
        captured_output = []
        error = proc do |l|
          captured_output << l
        end
        output = U3dCore::CommandExecutor.execute(command: "ruby -e 'exit 1'", error: error)
        expect(captured_output).to eq(["Exit status: 1".red])
        expect(output).to eq("Exit status: 1".red)
      end

      it "allows to test I/O buffering" do
        command = "ruby -e '5.times{sleep 0.1; puts \"HI\"}'"
        output = U3dCore::CommandExecutor.execute(command: command, print_all: true)
        expect(output).to eq("HI\nHI\nHI\nHI\nHI")
      end
    end
  end
end
