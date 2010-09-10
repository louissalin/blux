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
		
		@io = mock("IO")
		def @io.<<(str) end
		@manager = DraftManager.new('gedit', @temp_dir, @draft_dir, @io)
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

	context "when editing a draft" do
		before :each do
			@manager.stub!(:system).and_return(nil)
		end

		it "should call the editor command" do
			system "touch #{@draft_dir}/test.sh"

			@manager.should_receive(:system).with("gedit #{@draft_dir}/test.sh")
			@manager.edit_draft('test.sh')
		end

		it "should show an error if the file doesn't exist" do
			@io.should_receive(:<<).with('draft filename asdf.asf does not exist')
			@manager.edit_draft('asdf.asf')
		end
	end

	context "when listing drafts" do
		before :each do
			system "touch #{@draft_dir}/1"
			system "touch #{@draft_dir}/2"
			system "touch #{@draft_dir}/3"
		end

		it "should list all the draft filenames, one per line" do
			@manager.list.should == "1\n2\n3"
		end
	end

	context "when displaying info about a draft" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},"file1":{"a":1,"b":2}}')
			end

			system "touch #{@draft_dir}/file1"
			system "touch #{@draft_dir}/file2"

			@manager = DraftManager.new('gedit', @temp_dir, @draft_dir, @io)
		end

		it "should display the info about the selected draft in json format" do
			@manager.show_info('file1').should == '{"a":1,"b":2}'
		end

		it "should output an error message if the file does not exist" do
			@io.should_receive(:<<).with('draft filename asdf.asf does not exist')
			@manager.edit_draft('asdf.asf')
		end
	end
end

