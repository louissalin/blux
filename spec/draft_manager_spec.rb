require 'draft_manager.rb'
require 'tempfile'

describe DraftManager do
	before :each do
		@blux_dir = "#{File.dirname(__FILE__)}/.blux"
		@temp_dir = "#{@blux_dir}/tmp"
		@draft_dir = "#{@blux_dir}/draft"

		Dir.mkdir(@blux_dir) unless Dir.exists?(@blux_dir)
		Dir.mkdir(@temp_dir) unless Dir.exists?(@temp_dir)
		Dir.mkdir(@draft_dir) unless Dir.exists?(@draft_dir)
		
		@manager = DraftManager.new('gedit', @temp_dir, @draft_dir)
	end

	after :each do
		`rm -Rf #{@blux_dir}`
	end

	context "when creating a new draft" do
		before :each do
			@manager.stub!(:system).and_return(nil)
		end

		after :each do
			`rm -f #{@draft_dir}/*`
		end

		it "should call the editor command" do
			@manager.should_receive(:system).with('gedit')
			@manager.create_draft
		end

		it "should not copy the temp file in the draft folder if it has no data" do
			tempfile = mock("Tempfile")
			def tempfile.initialize(basename, path)
				system "touch #{@temp_dir}/test"
			end

			def tempfile.path
				"#{@temp_dir}/test"
			end

			@manager.create_draft
			Dir.entries(@draft_dir).length.should == 2 # . and ..
		end

		it "should copy the temp file in the draft folder if it has data" do
			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end

			@manager.should_receive(:system).with('gedit').ordered
			@manager.should_receive(:system).with("mv test/test.sh #{@draft_dir}").ordered
			@manager.create_draft
		end

		it "should delete the temp file from the tmp folder after copying it" do
			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end

			@manager.should_receive(:system).with('gedit').ordered
			@manager.should_receive(:system).with("mv test/test.sh #{@draft_dir}").ordered
			@manager.should_receive(:system).with("rm test/test.sh").ordered
			@manager.create_draft
		end
	end
end

