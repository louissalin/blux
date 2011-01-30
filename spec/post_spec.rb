require 'post'
require 'post_editor'
require 'repository'
require 'config'

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

describe Blux::Post, "when editing a post" do
	it "should use the post editor to edit the post" do
		post = Blux::Post.new('this is text')

		editor_mock = mock('editor_mock')
		Blux::PostEditor.should_receive(:instance).and_return(editor_mock)

		editor_mock.should_receive(:edit).with(post)
		post.edit
	end
end

describe Blux::Post, "when saving a post" do
	it "should use the repository to save the post" do
		post = Blux::Post.new('this is text')

		repo = mock('repository')
		Blux::Repository.should_receive(:instance).and_return(repo)

		repo.should_receive(:save).with(post)
		post.save
	end
end
