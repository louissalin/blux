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

		def STDERR.puts(str) end
		@manager = DraftManager.new()
		@manager.setup('gedit', @temp_dir, @draft_dir)
	end

	after :each do
		`rm -Rf #{@blux_dir}`
	end

	context "when using a new manager" do
		it "should have an empty draft index" do
			index = @manager.load_index
			index.keys.length.should == 0
		end

		it "should load the draft index from disk" do
			File.stub!(:exists?).and_return(true)

			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"test.sh":{"a":1,"b":2}}')
			end
			
			manager = DraftManager.new
			manager.setup('gedit', @temp_dir, @draft_dir)

			@manager.get_attribute('test.sh', "a").should == 1
			@manager.get_attribute('test.sh', "b").should == 2
		end
	end

	context "when using a new manager with no draft index" do
		it "should create an empty draft index" do
			File.exists?("#{@draft_dir}/.draft_index").should == true
		end
	end

	context "when creating a new draft" do
		before :each do
			@manager.stub!(:system).and_return(true)
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
			Dir.entries(@draft_dir).length.should == 3 # . and .. and .index
		end

		it "should copy the temp file in the draft folder if it has data" do
			File.stub!(:exists?).and_return(true)

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
			@manager.stub!(:system).and_return(true)
			File.stub!(:exists?).and_return(true)

			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end
		end

		after :each do
			`rm -f #{@draft_dir}/*`
		end

		it "should save the draft index to disk" do
			@manager.create_draft
			File.exists?("#{@draft_dir}/.draft_index").should == true
		end

		it "should add the creation time to the attributes of that draft" do
			time = Time.now.to_s
			@manager.create_draft
			@manager.get_attribute('test.sh', "creation_time").to_s.should == time
		end
	end

	context "when editing a draft" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"test.sh":{}}')
			end

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
			@manager.stub!(:system).and_return(true)
		end

		it "should call the editor command" do
			system "touch #{@draft_dir}/test.sh"

			@manager.should_receive(:system).with("gedit #{@draft_dir}/test.sh")
			@manager.edit_draft('test.sh')
		end

		it "should show an error if the file doesn't exist" do
			lambda {@manager.edit_draft('asdf.asf')}.should raise_error("draft filename asdf.asf does not exist")
		end

		it "should add the edited time to the attributes of that draft" do
			system "touch #{@draft_dir}/test.sh"
			time = Time.now.to_s

			@manager.edit_draft('test.sh')
			@manager.get_attribute('test.sh', "edited_time").to_s.should == time
		end
	end

	context "when listing drafts" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"1":{},"2":{},"3":{}}')
			end
		end

		it "should list all the draft filenames, one per line" do
			@manager.list.entries.should == ["1", "2", "3"]
		end
	end

	context "when requesting info about a draft" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},"file1":{"a":1,"b":2}}')
			end

			system "touch #{@draft_dir}/file1"
			system "touch #{@draft_dir}/file2"

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should display the info about the selected draft in json format" do
			@manager.show_info('file1').should == '{"a":1,"b":2}'
		end

		it "should output an error message if the file does not exist" do
			lambda {@manager.edit_draft('asdf.asf')}.should raise_error("draft filename asdf.asf does not exist")
		end
	end

	context "when showing a draft preview" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},"file2":{"a":1,"b":2}, "file3":{}}')
			end

			system "echo this is blog with lots of letters intended to go beyond the 76 chars that will be displayed by the preview functionnality of the draft manager > #{@draft_dir}/file1"
			system "echo this is a blog > #{@draft_dir}/file2"
			system "touch #{@draft_dir}/file3"

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should trunk the preview to 76 chars, with '...' appended at the end" do
			@manager.show_preview('file1').should == 'this is blog with lots of letters intended to go beyond the 76 chars that wi...'
		end

		it "should display the first line as is if it doesn't have more than 76 chars" do
			@manager.show_preview('file2').should == 'this is a blog'
		end

		it "should display an empty string for an empty draft" do
			@manager.show_preview('file3').should == ''
		end
	end

	context "when outputing a draft" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},
						  "file2":{"a":1,"deleted":"2010-10-15 00:00:00"}, 
						  "file3":{}}')
			end

			system "echo this is blog with lots of letters intended to go beyond the 76 chars that will be displayed by the preview functionnality of the draft manager > #{@draft_dir}/file1"
			system "echo this is a blog > #{@draft_dir}/file2"
			system "touch #{@draft_dir}/file3"

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should show the entire content of the draft" do
			@manager.output('file1').should == "this is blog with lots of letters intended to go beyond the 76 chars that will be displayed by the preview functionnality of the draft manager\n"
		end

		it "should display an empty string for an empty draft" do
			@manager.output('file3').should == ''
		end

		it "should raise an exception if the draft has been deleted" do
			lambda {@manager.output('file2')}.should raise_error("draft filename file2 has been deleted")
		end
	end

	context "when adding an attribute" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"draft.1":{}}')
			end

			system "touch #{@draft_dir}/draft.1"
			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should add the attribute to the draft index" do
			@manager.set_attribute('draft.1', "attr", "123")
			@manager.get_attribute('draft.1', "attr").should == "123"
		end

		it "should overwrite the value if the attribute already exists" do
			@manager.set_attribute('draft.1', "attr", "123")
			@manager.set_attribute('draft.1', "attr", "456")
			@manager.get_attribute('draft.1', "attr").should == "456"
		end

		it "should output an error message if the file does not exist" do
			lambda {@manager.set_attribute('asdf.asf', "attr", "456")}.should raise_error("draft filename asdf.asf does not exist")
		end

		it "should save the draft index to disk" do
			File.should_receive(:open).with("#{@draft_dir}/.draft_index", 'r')
			File.should_receive(:open).with("#{@draft_dir}/.draft_index", 'w')
			@manager.set_attribute('draft.1', "attr", "123")
		end
	end

	context "when adding a title" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"draft.1":{},"draft.2":{}}')
			end

			system "touch #{@draft_dir}/draft.1"
			system "touch #{@draft_dir}/draft.2"
			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should output an warning message if the title is not unique" do
			@manager.set_attribute('draft.1', "title", 'title')

			STDERR.stub!(:<<)
			STDERR.should_receive(:<<).with("warning: title 'title' is not unique\n")
			@manager.set_attribute('draft.2', "title", 'title')
		end

		it "should still change the value of the previous title" do
			STDERR.stub!(:<<)
			@manager.set_attribute('draft.1', 'title', 'title')
			@manager.set_attribute('draft.2', 'title', 'title2')
			@manager.set_attribute('draft.2', 'title', 'title')

			@manager.get_attribute('draft.2', "title").should == "title"
		end
	end

	context "when adding a tag" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"draft.1":{}}')
			end

			system "touch #{@draft_dir}/draft.1"
			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should add a new tags attribute" do
			@manager.set_attribute('draft.1', 'categories', "a tag")
			@manager.get_attribute('draft.1', "categories").should == "a tag"
		end

		it "should add to an existing tag attribute if it already exists" do
			@manager.set_attribute('draft.1', 'categories', "a tag")
			@manager.set_attribute('draft.1', 'categories', "another tag")
			@manager.get_attribute('draft.1', "categories").should == "a tag,another tag"
		end
	end

	context "when deleting a tag" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"draft.1":{"categories":"tag1,tag2,tag3"}}')
			end

			system "touch #{@draft_dir}/draft.1"
			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should remove the attribute from the draft index" do
			@manager.delete_attribute('draft.1', "categories") do
				'tag2'
			end
			
			@manager.get_attribute('draft.1', "categories").should == "tag1,tag3"
		end

		it "should not do anything if the tag does not exist" do
			@manager.delete_attribute('draft.1', "categories") do
				'tag5'
			end
			
			@manager.get_attribute('draft.1', "categories").should == "tag1,tag2,tag3"
		end

		it "should remove the attribute if there are no tags left" do
			@manager.delete_attribute('draft.1', "categories") do
				'tag1,tag2,tag3'
			end
			
			@manager.get_attribute('draft.1', "categories").should == nil
		end
	end

	context "when deleting an attribute" do
		before :each do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write('{"draft.1":{"a":1,"b":2}}')
			end

			system "touch #{@draft_dir}/draft.1"
			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
		end

		it "should remove the attribute from the draft index" do
			@manager.delete_attribute('draft.1', :a)
			@manager.get_attribute('draft.1', "a").should == nil
		end

		it "should output an error message if the file does not exist" do
			lambda {@manager.delete_attribute('asdf.asf', :attr)}.should raise_error("draft filename asdf.asf does not exist")
		end

		it "should save the draft index to disk" do
			File.stub!(:open)
			File.should_receive(:open).with("#{@draft_dir}/.draft_index", 'w')
			@manager.delete_attribute('draft.1', :attr)
		end
	end

	context "when requesting the latest created draft" do
		it "should return the latest draft filename" do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write({"draft.1" => {"creation_time" => "2010-10-10 15:30:12"},
						 "draft.2" => {"creation_time" => "2010-10-09 15:30:12"}}.to_json)
			end

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)

			@manager.get_latest_created_draft().should == "draft.1"
		end

		it "should output an error message if there are no drafts saved" do
			lambda {@manager.get_latest_created_draft}.should raise_error("there is currently no saved index")
		end

		it "should not take deleted drafts into account" do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write({"draft.1" => {"creation_time" => "2010-10-11 15:30:12",
									   "deleted" => "2010-10-15 00:00:00"},
						 "draft.2" => {"creation_time" => "2010-10-10 15:30:12"},
						 "draft.3" => {"creation_time" => "2010-10-09 15:30:12"}}.to_json)
			end

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)

			@manager.get_latest_created_draft().should == "draft.2"
		end
	end

	context "when requesting a draft by title" do
		it "should return the the proper filename" do
			File.open("#{@draft_dir}/.draft_index", 'w') do |f|
				f.write({"draft.1" => {"title" => "title1"},
						 "draft.2" => {"title" => "title2"}}.to_json)
			end

			@manager = DraftManager.new
			@manager.setup('gedit', @temp_dir, @draft_dir)
			
			@manager.get_draft_by_title("title1").should == "draft.1"
			@manager.get_draft_by_title("title2").should == "draft.2"
		end

		it "should output an error message if there are no drafts saved" do
			lambda {@manager.get_draft_by_title("title2")}.should raise_error("there is currently no saved index")
		end
	end
end

