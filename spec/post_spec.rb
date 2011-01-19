require 'post'
require 'config'
require 'tempfile'

describe Blux::Post, "when creating a new post" do
	before :each do
		@post = Blux::Post.new('this is text')
	end

	it "should initialize an empty post with a creation date of now" do
		time = Time.now

		@post.text.should eq('this is text')
		@post.creation_date.min.should eq(time.min)
		@post.creation_date.hour.should eq(time.hour)
		@post.creation_date.day.should eq(time.day)
		@post.creation_date.month.should eq(time.month)
		@post.creation_date.year.should eq(time.year)
	end

	it "should not have a category" do
		@post.category.should eq('')
	end

	it "should not have a title" do
		@post.title.should eq('')
	end
end

describe Blux::Post, "when preparing to edit a post" do
	before :all do
		class Blux::PostFile
			def initialize
			end
		end
	end

	before :each do
		Blux::Config.instance.editor_cmd = 'some_editor_cmd'
		@post = Blux::Post.new('this is text')
	end

	it "should create a temp file to hold the text" do
		Blux::PostFile.should_receive(:new)
		@post.edit
	end

	it "should fille the post file with the post's text" do
		Blux::PostFile.should_receive(:text=).with('this is text')
		@post.edit
	end

	it "should launch the editor defined in the config" do
		@post.should_receive(:system).with('some_editor_cmd')
		@post.edit
	end
end

describe Blux::PostFile, "when creating a post file" do
	it "should create a temp file" do
		Tempfile.should_receive(:new).with('blux')
		postFile = Blux::PostFile.new
	end
end
