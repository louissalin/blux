require 'post_manager.rb'
require 'tempfile'

describe PostManager do
	before :each do
		@blux_dir = "#{File.dirname(__FILE__)}/.blux"
		@temp_dir = "#{@blux_dir}/tmp"
		@post_dir = "#{@blux_dir}/post"

		Dir.mkdir(@blux_dir) unless Dir.exists?(@blux_dir)
		Dir.mkdir(@temp_dir) unless Dir.exists?(@temp_dir)
		Dir.mkdir(@post_dir) unless Dir.exists?(@post_dir)

		def STDERR.puts(str) end
		@manager = PostManager.new()
		@manager.setup('gedit', @temp_dir, @post_dir)
	end

	after :each do
		`rm -Rf #{@blux_dir}`
	end

	context "when using a new manager" do
		it "should have an empty post index" do
			index = @manager.load_index
			index.keys.length.should == 0
		end

		it "should load the post index from disk" do
			File.stub!(:exists?).and_return(true)

			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"test.sh":{"a":1,"b":2}}')
			end
			
			manager = PostManager.new
			manager.setup('gedit', @temp_dir, @post_dir)

			@manager.get_attribute('test.sh', "a").should == 1
			@manager.get_attribute('test.sh', "b").should == 2
		end
	end

	context "when using a new manager with no post index" do
		it "should create an empty post index" do
			File.exists?("#{@post_dir}/.post_index").should == true
		end
	end

	context "when creating a new post" do
		before :each do
			@manager.stub!(:system).and_return(true)
		end

		after :each do
			`rm -f #{@post_dir}/*`
		end

		it "should call the editor command" do
			class Tempfile
				def path() 'test/test.sh' end
			end

			@manager.should_receive(:system).with('gedit test/test.sh')
			@manager.create_post
		end

		it "should not copy the temp file in the post folder if it has no data" do
			tempfile = mock("Tempfile")
			def tempfile.initialize(basename, path)
				system "touch #{@temp_dir}/test"
			end

			def tempfile.path
				"#{@temp_dir}/test"
			end

			@manager.create_post
			Dir.entries(@post_dir).length.should == 3 # . and .. and .index
		end

		it "should copy the temp file in the post folder if it has data" do
			File.stub!(:exists?).and_return(true)

			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end

			@manager.should_receive(:system).with('gedit test/test.sh').ordered
			@manager.should_receive(:system).with("mv test/test.sh #{@post_dir}").ordered
			@manager.create_post
		end

		it "should create a post object with the filename set" do
			File.stub!(:exists?).and_return(true)

			class Tempfile
				def path() 'test/test.sh' end
			end

			post = @manager.create_post
			post.filename.should == 'test.sh'
		end
	end

	context "when saving a new post" do
		before :each do
			@manager.stub!(:system).and_return(true)
			File.stub!(:exists?).and_return(true)

			class Tempfile
				def size() 123 end
				def path() 'test/test.sh' end
			end
		end

		after :each do
			`rm -f #{@post_dir}/*`
		end

		it "should save the post index to disk" do
			@manager.create_post
			File.exists?("#{@post_dir}/.post_index").should == true
		end

		it "should add the creation time to the attributes of that post" do
			time = Time.now.to_s
			post = @manager.create_post
			post.creation_time.to_s.should == time
		end
	end

	context "when editing a post" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"test.sh":{}}')
			end

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
			@manager.stub!(:system).and_return(true)
		end

		it "should call the editor command" do
			system "touch #{@post_dir}/test.sh"

			@manager.should_receive(:system).with("gedit #{@post_dir}/test.sh")
			@manager.edit_post('test.sh')
		end

		it "should show an error if the file doesn't exist" do
			lambda {@manager.edit_post('asdf.asf')}.should raise_error("post filename asdf.asf does not exist")
		end

		it "should add the edited time to the attributes of that post" do
			system "touch #{@post_dir}/test.sh"
			time = Time.now.to_s

			@manager.edit_post('test.sh')
			@manager.get_attribute('test.sh', "edited_time").to_s.should == time
		end
	end

	context "when listing posts" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"1":{},"2":{},"3":{}}')
			end
		end

		it "should list all the post filenames, one per line" do
			@manager.list.entries.should == ["1", "2", "3"]
		end
	end

	context "when requesting info about a post" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},"file1":{"a":1,"b":2}}')
			end

			system "touch #{@post_dir}/file1"
			system "touch #{@post_dir}/file2"

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
		end

		it "should display the info about the selected post in json format" do
			@manager.show_info('file1').should == '{"a":1,"b":2}'
		end

		it "should output an error message if the file does not exist" do
			lambda {@manager.edit_post('asdf.asf')}.should raise_error("post filename asdf.asf does not exist")
		end
	end

	context "when showing a post preview" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},"file2":{"a":1,"b":2}, "file3":{}}')
			end

			system "echo this is blog with lots of letters intended to go beyond the 76 chars that will be displayed by the preview functionnality of the post manager > #{@post_dir}/file1"
			system "echo this is a blog > #{@post_dir}/file2"
			system "touch #{@post_dir}/file3"

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
		end

		it "should trunk the preview to 76 chars, with '...' appended at the end" do
			@manager.show_preview('file1').should == 'this is blog with lots of letters intended to go beyond the 76 chars that wi...'
		end

		it "should display the first line as is if it doesn't have more than 76 chars" do
			@manager.show_preview('file2').should == 'this is a blog'
		end

		it "should display an empty string for an empty post" do
			@manager.show_preview('file3').should == ''
		end
	end

	context "when outputing a post" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"file1":{"a":1,"b":2},
						  "file2":{"a":1,"deleted":"2010-10-15 00:00:00"}, 
						  "file3":{}}')
			end

			system "echo this is blog with lots of letters intended to go beyond the 76 chars that will be displayed by the preview functionnality of the post manager > #{@post_dir}/file1"
			system "echo this is a blog > #{@post_dir}/file2"
			system "touch #{@post_dir}/file3"

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
		end

		it "should show the entire content of the post" do
			@manager.output('file1').should == "this is blog with lots of letters intended to go beyond the 76 chars that will be displayed by the preview functionnality of the post manager\n"
		end

		it "should display an empty string for an empty post" do
			@manager.output('file3').should == ''
		end

		it "should raise an exception if the post has been deleted" do
			lambda {@manager.output('file2')}.should raise_error("post filename file2 has been deleted")
		end
	end

	context "when adding an attribute" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"post.1":{}}')
			end

			system "touch #{@post_dir}/post.1"
			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
		end

		it "should add the attribute to the post index" do
			@manager.set_attribute('post.1', "attr", "123")
			@manager.get_attribute('post.1', "attr").should == "123"
		end

		it "should overwrite the value if the attribute already exists" do
			@manager.set_attribute('post.1', "attr", "123")
			@manager.set_attribute('post.1', "attr", "456")
			@manager.get_attribute('post.1', "attr").should == "456"
		end

		it "should output an error message if the file does not exist" do
			lambda {@manager.set_attribute('asdf.asf', "attr", "456")}.should raise_error("post filename asdf.asf does not exist")
		end

		it "should save the post index to disk" do
			File.should_receive(:open).with("#{@post_dir}/.post_index", 'r')
			File.should_receive(:open).with("#{@post_dir}/.post_index", 'w')
			@manager.set_attribute('post.1', "attr", "123")
		end
	end

	context "when deleting an attribute" do
		before :each do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write('{"post.1":{"a":1,"b":2}}')
			end

			system "touch #{@post_dir}/post.1"
			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
		end

		it "should remove the attribute from the post index" do
			@manager.delete_attribute('post.1', :a)
			@manager.get_attribute('post.1', "a").should == nil
		end

		it "should output an error message if the file does not exist" do
			lambda {@manager.delete_attribute('asdf.asf', :attr)}.should raise_error("post filename asdf.asf does not exist")
		end

		it "should save the post index to disk" do
			File.stub!(:open)
			File.should_receive(:open).with("#{@post_dir}/.post_index", 'w')
			@manager.delete_attribute('post.1', :attr)
		end
	end

	context "when requesting the latest created post" do
		it "should return the latest post filename" do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write({"post.1" => {"creation_time" => "2010-10-10 15:30:12"},
						 "post.2" => {"creation_time" => "2010-10-09 15:30:12"}}.to_json)
			end

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)

			@manager.get_latest_created_post().should == "post.1"
		end

		it "should output an error message if there are no post saved" do
			lambda {@manager.get_latest_created_post}.should raise_error("there is currently no saved index")
		end

		it "should not take deleted post into account" do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write({"post.1" => {"creation_time" => "2010-10-11 15:30:12",
									   "deleted" => "2010-10-15 00:00:00"},
						 "post.2" => {"creation_time" => "2010-10-10 15:30:12"},
						 "post.3" => {"creation_time" => "2010-10-09 15:30:12"}}.to_json)
			end

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)

			@manager.get_latest_created_post().should == "post.2"
		end
	end

	context "when requesting a post by title" do
		it "should return the the proper filename" do
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write({"post.1" => {"title" => "title1"},
						 "post.2" => {"title" => "title2"}}.to_json)
			end

			@manager = PostManager.new
			@manager.setup('gedit', @temp_dir, @post_dir)
			
			@manager.get_post_by_title("title1").should == "post.1"
			@manager.get_post_by_title("title2").should == "post.2"
		end

		it "should output an error message if there are no post saved" do
			lambda {@manager.get_post_by_title("title2")}.should raise_error("there is currently no saved index")
		end
	end

	context "when accessing a post" do
		before(:each) do
			system "touch #{@post_dir}/post.23"

			@time = "2010-10-09 00:00:00"
			@time2 = "2011-10-09 00:00:00"
			File.open("#{@post_dir}/.post_index", 'w') do |f|
				f.write({"post.23" => {"title" => "title1",
									   "creation_time" => @time,
									   "published_time" => @time2,
									   "categories" => "cat1,cat2"},
						 "post.45" => {}}.to_json)
			end

			@post = @manager.get_post('post.23')
		end

		it "should return the right post" do
			@post.filename.should == 'post.23'
		end

		it "should raise an exception if the post does not exist" do
			lambda {@manager.get_post('123.45')}.should raise_error("post filename 123.45 does not exist")
		end

		it "should load the creation_time attribute" do
			@post.creation_time.should == Time.parse(@time)
		end

		it "should load the published_time attribute" do
			@post.published_time.should == Time.parse(@time2)
		end

		it "should load the title attribute" do
			@post.title.should == 'title1'
		end

		it "should load the categories" do
			@post.categories.should == 'cat1,cat2'
		end
	end
end

