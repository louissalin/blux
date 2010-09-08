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

	context "when using a new manager" do
		it "should have an empty draft index" do
			@manager.draft_index.keys.length.should == 0
		end

		it "should load the draft index from disk" do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"test.sh":{"a":1,"b":2}}')
			end
			
			manager = DraftManager.new('gedit', @temp_dir, @draft_dir)
			manager.draft_index.key?("test.sh").should == true
			manager.draft_index["test.sh"].key?("a").should == true
			manager.draft_index["test.sh"].key?("b").should == true
		end
	end

	context "when using a new manager with no draft index" do
		it "should create an empty draft index" do
			File.exists?("#{@draft_dir}/.draft_index").should == true
		end
	end

	context "when creating a new draft" do
		before :each do
			@manager.stub!(:system).and_return(nil)
		end

		after :each do
			`rm -f #{@draft_dir}/*`
		end

		it "should call the editor command" do
			class Tempfile
				def path() 'test/test.sh' end
			end

			@manager.should_receive(:system).with('gedit test/test.sh')
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
			Dir.entries(@draft_dir).length.should == 3 # . and .. and .draft_index
		end

		it "should copy the temp file in the draft folder if it has data" do
			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end

			@manager.should_receive(:system).with('gedit test/test.sh').ordered
			@manager.should_receive(:system).with("mv test/test.sh #{@draft_dir}").ordered
			@manager.create_draft
		end
	end

	context "when saving a new draft" do
		before :each do
			@manager.stub!(:system).and_return(nil)

			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end
		end

		after :each do
			`rm -f #{@draft_dir}/*`
		end

		it "should create an entry in the draft index with empty attributes" do
			@manager.create_draft
			@manager.draft_index["test/test.sh"].should == {}
		end

		it "should save the draft index to disk" do
			@manager.create_draft
			File.exists?("#{@draft_dir}/.draft_index").should == true
		end
	end
end

